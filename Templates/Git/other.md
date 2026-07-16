# Push {{PROJECT}} to another Git host

The pattern is the same for any Git host:

1. **Add your SSH key** to your account (see the SSH keys tab), on the host's
   SSH-keys settings page.
2. **Create an empty repository** named `{{PROJECT}}` — do not let the host add a
   README, .gitignore, or license; your project already has them. Copy the
   repository's SSH URL.
3. **Push your project** from its folder:

        git init
        git add .
        git commit -m "Initial commit"
        git branch -M main
        git remote add origin <the SSH URL you copied>
        git push -u origin main

> Some hosts create the repository automatically on first push instead of
> requiring an empty repo first — check your host's documentation.
