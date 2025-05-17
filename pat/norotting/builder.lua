local _build = build
function build(directory, config, params, level, seed)
  if _build then
    config, params = _build(directory, config, params, level, seed)
  end

  if config.pat_norotting then
    jremove(params, "timeToRot")

    if config.tooltipFields then
      jremove(config.tooltipFields, "rotTimeLabel")
    end

    if params.tooltipFields then
      jremove(params.tooltipFields, "rotTimeLabel")
    end
  end

  return config, params
end
