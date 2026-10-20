export const WeztermAttention = async ({ $ }) => {
  if (!process.env.WEZTERM_PANE) return {}

  const script = `${process.env.HOME}/.config/wezterm/attention.sh`
  const flag = (mode) =>
    $`${script} ${mode} < /dev/null`.quiet().nothrow()

  return {
    event: async ({ event }) => {
      if (
        event.type === 'session.idle' ||
        event.type === 'permission.asked' ||
        event.type === 'session.error'
      ) {
        await flag('set')
      }
    },
  }
}
