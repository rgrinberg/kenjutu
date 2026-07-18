local t = require("tests.test")
local jj = require("kenjutu.jj")

t.run_case("fetch_commits_metadata batches revisions in one jj process", function()
  local original_system = vim.system
  local command
  local result

  rawset(vim, "system", function(cmd, _, callback)
    command = cmd
    callback({
      code = 0,
      stdout = table.concat({
        "bbbb2222",
        "destination summary\ndestination body",
        "Destination Author",
        "2 minutes ago",
        "aaaa1111",
        "source summary",
        "Source Author",
        "1 minute ago",
        "",
      }, "\0"),
    })
  end)

  jj.fetch_commits_metadata("/repo", { "aaaa1111", "bbbb2222" }, function(err, metadata_by_change_id)
    t.eq(err, nil)
    result = metadata_by_change_id
  end)
  vim.wait(1000, function()
    return result ~= nil
  end)
  rawset(vim, "system", original_system)

  t.eq(command[1], "jj")
  t.eq(command[2], "log")
  t.eq(command[3], "--ignore-working-copy")
  t.eq(command[#command - 3], "-r")
  t.eq(command[#command - 2], "aaaa1111")
  t.eq(command[#command - 1], "-r")
  t.eq(command[#command], "bbbb2222")
  t.eq(result.aaaa1111.summary, "source summary")
  t.eq(result.aaaa1111.author, "Source Author")
  t.eq(result.bbbb2222.description, "destination body")
  t.eq(result.bbbb2222.timestamp, "2 minutes ago")
end)
