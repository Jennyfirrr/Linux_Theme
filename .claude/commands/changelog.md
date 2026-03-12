Update the changelog with recent changes.

Instructions:
1. Read CHANGELOG.md to see the last recorded entry
2. Run `git log --format="%H %ad %s" --date=short` to see all commits
3. Identify any commits that happened AFTER the most recent changelog date
4. If there are no new commits, tell the user "Changelog is already up to date"
5. If there are new commits, group them by date and category:
   - Categories: Neovim, Hyprland, Shell, Theme, Wallpaper, Docs, Other
   - Read the actual diffs with `git show --stat <hash>` to understand what changed
   - Write clear, user-facing descriptions (not just commit messages)
6. Add the new entries at the TOP of the changelog (below the header), keeping the existing entries
7. Use the same formatting style as existing entries (## date, ### category, bullet points)
8. After updating, copy any changed config files to their live locations if applicable
9. Stage and commit the changelog update, then push to remote
