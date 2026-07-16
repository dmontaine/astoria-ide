# SSH keys

An SSH key lets you push to your repository without typing a password each time.
You only need to set it up once per computer.

**Public key only** — never share or paste your *private* key (the file *without*
the `.pub` extension).

## 1. Check whether you already have a key

Look in your `.ssh` folder (`%USERPROFILE%\.ssh\` on Windows) for `id_ed25519.pub`.
If it's there, you already have a key — skip to step 3.

## 2. Create a key (only if you don't have one)

In a terminal:

    ssh-keygen -t ed25519 -C "your_email@example.com"

Press Enter to accept the default location. A passphrase is optional but recommended.

## 3. Copy your public key

Open `id_ed25519.pub` and copy its entire contents (one line starting with
`ssh-ed25519`). Paste it into your Git host's **SSH keys** settings page — see the
host-specific steps.

> Verify the current key type and the settings-page location for your host at the
> time of writing; these occasionally change.
