# Push {{PROJECT}} to GitLab

> Verify these steps against GitLab's current interface — host UIs change over time.

## 1. Add your SSH key
Preferences → **SSH Keys** → **Add new key** → paste the public key from the SSH keys tab.

## 2. Create an empty repository
Click **New project** → **Create blank project**. Name it `{{PROJECT}}`. **Do not** add a README, .gitignore, or license —
your project already has them.

## 3. Push your project
From your project folder:

    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git remote add origin git@gitlab.com:<your-username>/{{PROJECT}}.git
    git push -u origin main
