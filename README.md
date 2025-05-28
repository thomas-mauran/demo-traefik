# demo-traefik

### Problems tracking

- Issue with Vagrant on macOS:
    Description: 
    ```
    There was an error while executing `VBoxManage`, a CLI used by Vagrant
    for controlling VirtualBox. The command and stderr is shown below.

    Command: ["startvm", "e1e0e3d4-1cf3-41e2-9f92-11c2c7475fa0", "--type", "headless"]

    Stderr: VBoxManage: error: The VM session was aborted
    VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component SessionMachine, interface ISession
    ```

    Solution: 
    - https://forums.virtualbox.org/viewtopic.php?t=102615
    - Install extra packages for VirtualBox:
    - use a ARM image of ubuntu, since I am on an M1 Mac.