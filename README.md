# File Backup Automation

Shell Script project for automating file backups using `rsync`.

The script allows users to configure multiple source directories, define a destination directory, simulate the backup process before execution, and optionally generate a log file containing the operation report.

## Features

- Source and destination directory validation
- Support for multiple source directories
- Backup simulation before real execution
- Optional log file generation
- Confirmation step before executing the backup
- Ability to perform multiple backups without restarting the program manually

## Technologies Used

- Shell Script
- Bash
- rsync

## How to Run

Give execution permission to the script:

```bash
chmod +x backup.sh
```

Run the script:

```bash
./backup.sh
```

## Requirements

`rsync` must be installed on the system.

For Debian/Ubuntu-based distributions:

```bash
sudo apt install rsync
```

## Notes

This project was developed as a systems administration practice project, focusing on automation, directory management, input validation, and backup operations through the terminal.
