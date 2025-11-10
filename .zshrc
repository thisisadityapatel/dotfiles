# Spaceship prompt
source /opt/homebrew/opt/spaceship/spaceship.zsh

# Node Version Manager (NVM)
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"
[ -s "$(brew --prefix nvm)/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix nvm)/etc/bash_completion.d/nvm"

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Take screenshot
function screenshot() {
  local seconds=0
  if [[ $1 ]]; then
    seconds=$1
  fi

  screencapture -x -T "$seconds" -t png \
    ~/Desktop/screenshot-$(date +"%Y-%m-%d-%H-%M-%S").png
}

# Checkout master/main branch
function main() {
  if git show-ref --quiet refs/heads/main; then
    git checkout main
  else
    git checkout master
  fi
}

# Fix camera when macOS camera stops working occasionally
function fixcamera() {
  sudo killall VDCAssistant
}

# Fix Postgres after force shutdown or crash
function fixpg() {
  rm -f /usr/local/var/postgres/postmaster.pid
  brew services restart postgresql

  echo 'If still not working, try:'
  echo '  pg_ctl -D /usr/local/var/postgres start'
  echo 'or on M1:'
  echo '  pg_ctl -D /opt/homebrew/var/postgres start'
}

# Kill process running on a specific port
function killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local port=$1
  local pid
  pid=$(lsof -ti :$port)

  if [[ -z "$pid" ]]; then
    echo "No process found running on port $port"
    return 0
  fi

  kill -9 "$pid" && echo "Killed process $pid running on port $port"
}

# Kill and remove all running docker containers.
function docker-killall() {
  local containers
  containers=$(docker ps -q)

  if [[ -z "$containers" ]]; then
    echo "No containers running."
    return 0
  fi

  echo "Containers currently running:"
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
  echo
  echo "Are you sure you want to stop and remove ALL running containers? (y/n)"
  read -r answer

  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "Stopping containers..."
    docker stop $containers >/dev/null

    echo "Removing containers..."
    docker rm $containers >/dev/null

    echo "✅ Done."
  else
    echo "Aborted. No containers were touched."
  fi
}

# Check Claude API daily cost
function ccost() {
  npx ccusage daily
}
