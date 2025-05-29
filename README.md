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

- `http: TLS handshake error from 10.42.0.18:42462: remote error: tls: bad certificate`
    Description: 
    Had this error when trying to access the API through the traefik reverse proxy.
    Didn't had the issue when accessing the API directly using port forwarding.

    Solution: 
    - I was using a kubernetes ingress not a traefik ingress.
    - Added `passthrough: true`, since the api is already using HTTPS with a self-signed certificate.
      I usually use cert-manager to manage certificates, but in this case it was specified to store the certificate in a pvc. Therefore the API was also written in a way that it can use a self-signed certificate. Meaning that the API is already using HTTPS and traefik should not terminate the TLS connection.

      