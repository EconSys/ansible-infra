# shellcheck disable=SC2148
# Store interactive shell history outside user home directories so SIEM
# ingestion can track commands performed through privilege escalation.
HISTBASEDIR="/var/log/bashhist"

# Only configure interactive Bash sessions. Avoid affecting
# scripts, cron jobs, and other non-interactive processes.
if [[ $- == *i* ]] && [[ -d "$HISTBASEDIR" ]]; then

  # EFFNAME is the account currently executing commands.
  # REALNAME preserves the user who originally connected
  # (for example, user1 becoming root with sudo -i).
  EFFNAME="$(id -un)"
  REALNAME="$(who am i 2>/dev/null | awk '{print $1}')"

  # Some session types (for example SSM or non-TTY shells) may not
  # provide utmp information for "who am i".
  REALNAME="${REALNAME:-${SUDO_USER:-$EFFNAME}}"

  # Create a separate history directory per effective user.
  # The directory structure is consumed by Splunk field extraction:
  # /var/log/bashhist/<effective_user>/history-<real_user>
  install -o root -g root -m 0700 -d "$HISTBASEDIR/$EFFNAME"

  # Preserve commands across multiple shell sessions and keep timestamps
  # so SIEM events include when commands were executed.
  shopt -s histappend
  shopt -s lithist
  shopt -s cmdhist

  # Keep terminal resizing behavior consistent with normal Bash defaults.
  shopt -s checkwinsize

  # Do not allow users to hide commands by ignoring duplicates or
  # commands beginning with spaces.
  unset HISTCONTROL
  unset HISTIGNORE

  export HISTSIZE=10000
  export HISTTIMEFORMAT="%F %T "

  export HISTFILE="$HISTBASEDIR/$EFFNAME/history-$REALNAME"

  # Write history after every command instead of only when the shell exits.
  # This prevents losing history from disconnected SSH/SSM sessions.
  PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

  # terminal prompt
  PS1="[\u@\h \w]\\$ "
fi