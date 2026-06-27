use std::path::PathBuf;

use tauri::command;

use super::{Error, Result};

/// Validate that a directory has a Git repository, either directly or as the
/// backing store of a jj workspace.
/// This is called from the frontend before saving the local path.
#[command]
#[specta::specta]
pub async fn validate_git_repo(local_dir: PathBuf) -> Result<()> {
    if kenjutu_core::services::git::open_repository(&local_dir).is_err() {
        return Err(Error::bad_input(format!(
            "Directory {} is not a git-backed jj repository",
            local_dir.display()
        )));
    }
    Ok(())
}
