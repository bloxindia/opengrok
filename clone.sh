REPO_DIR="/opengrok/src"
EXCLUDED_REPOS=(
  "Website_2.0_deprecated"
  "kapleshwara-residency"
  "old-mc"
  "codenameworklife"
  "microsite_custom_theme"
  "Blox-labs-website"
  "codename-bigbonanza"
  "kapleshwara-residency"
  "marketing-microsites"
  "test"
  "metabase"
)

# Ensure the repository directory exists
mkdir -p "$REPO_DIR"
cd "$REPO_DIR" || { echo "Failed to navigate to $REPO_DIR"; exit 1; }

for repo in "${REPOS[@]}"; do
  REPO_NAME=$(basename "$repo" .git)

  # Check if the repository is in the excluded list
  if [[ " ${EXCLUDED_REPOS[@]} " =~ " ${REPO_NAME} " ]]; then
    echo "Skipping excluded repository: $repo"
    continue
  fi

  REPO_PATH="$REPO_DIR/$REPO_NAME"

  if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Checking for branches in repository: $repo"

    # Check for the prod, main, or master branch and clone accordingly
    BRANCH=$(git ls-remote --heads "$repo" | awk '/refs\/heads\/(prod|main|master)/ {print $2}' | sed 's|refs/heads/||' | head -n 1)

    if [ -n "$BRANCH" ]; then
      echo "Cloning $BRANCH branch of repository: $repo into $REPO_PATH"
      git clone --branch "$BRANCH" --single-branch "$repo" "$REPO_PATH"
    else
      echo "No prod, main, or master branch found for repository: $repo. Skipping."
    fi
  else
    echo "Repository already exists in $REPO_PATH. Pulling the latest changes."
    cd "$REPO_PATH" || { echo "Failed to navigate to $REPO_PATH"; exit 1; }

    # Check the current branch and pull updates
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "Current branch: $CURRENT_BRANCH"
    git pull origin "$CURRENT_BRANCH" || echo "Failed to pull the latest changes for $repo"

    # Return to the repository directory
    cd "$REPO_DIR"
  fi
done
