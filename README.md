# linux_server_check.sh

Linux Server Check Bash-Script

For any suggestions or bugs, feel free to report them in the [**Issues**](https://github.com/thallmann/linux_server_check/issues)
page.

![Linux_Server_Check](./linux_server_check_v0_13_7.png "Linux Server Check Bash-Script")

Currently the following things are going to be checked:

- Hostname
- OS
- Uptime
- Number of package updates
- IP addresses
- Active nameservers
- Open Ports
- NTP servers
- Failed services
- Top 5 biggest logfiles
- Check for installation of some services
- Hosted apache websites
- Logged in users
- Last login attempts

# Usage

To execute the script please read its content, using your prefered editor, and then 

```
$ git clone https://github.com/thallmann/linux_server_check
$ bash ./linux_server_check/linux_server_check.sh 
```

# Compatibility

The script was tested on the following distros:
- SUSE Linux Enterprise Server 15
