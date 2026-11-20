local M = {}

M.defaults = {
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = 'dark',
    floats = 'dark',
  },
  dim_inactive = false,
  on_colors = function(_colors) end,
  on_highlights = function(_highlights, _colors) end,
}

M.options = nil

-- Derived from arvore-dark.json
-- stylua: ignore
local palette = {
  bg           = '#0d2221',
  bg_dark      = '#0a1b19',
  bg_darker    = '#051917',
  bg_float     = '#12292a',
  bg_highlight = '#102b28',
  bg_popup     = '#12292a',
  bg_sidebar   = '#0a1b19',
  bg_statusline = '#051917',
  bg_visual    = '#1d3d35',
  bg_search    = '#1d4343',
  border       = '#f3e7de',
  border_highlight = '#f4e6dd',
  comment      = '#759895',
  fg           = '#f5e6de',
  fg_dark      = '#ebcbb9',
  fg_gutter    = '#1c4644',
  fg_sidebar   = '#f5e6de',
  none         = 'NONE',

  -- Core palette
  black        = '#000400',
  red          = '#de7686',
  red1         = '#ff3655',
  green        = '#90dbd2',
  green1       = '#90dbd2',
  green2       = '#90dbd2',
  yellow       = '#ffc355',
  yellow1      = '#d6a446',
  orange       = '#ebcbb9',
  orange1      = '#ebcbb9',
  blue         = '#65d0f6',
  blue1        = '#479df3',
  blue2        = '#90dbd2',
  cyan         = '#b5b1d8',
  cyan1        = '#a7d4e4',
  cyan2        = '#a7d4e4',
  cyan3        = '#a7d4e4',
  teal         = '#90dbd2',
  purple       = '#9a92de',
  purple1      = '#6b5cec',
  purple2      = '#b5b1d8',
  magenta      = '#FC98AB',
  pink         = '#FDC3B1',

  -- Semantic
  error        = '#de7686',
  warning      = '#caa663',
  info         = '#759895',
  hint         = '#759895',
  todo         = '#a7d4e4',

  -- Terminal
  terminal_black = '#759895',

  -- Diff
  diff = {
    add    = '#1b2722',
    delete = '#1b1717',
    change = '#0d1b20',
    text   = '#102535',
  },

  -- Git
  git = {
    add    = '#21e7b1',
    change = '#b5b1d8',
    delete = '#de7686',
    ignore = '#2d5e5f',
  },

  -- Rainbow brackets
  rainbow = { '#fadfcb', '#f6c198', '#f0a05a', '#f0a05a', '#d57400', '#844700' },
}

---@param fg string foreground color
---@param alpha number number between 0 and 1
---@param bg string background color
function M.blend(fg, alpha, bg)
  local function rgb(c)
    c = string.lower(c)
    return { tonumber(c:sub(2, 3), 16), tonumber(c:sub(4, 5), 16), tonumber(c:sub(6, 7), 16) }
  end
  alpha = type(alpha) == 'string' and (tonumber(alpha, 16) / 0xff) or alpha
  local b = rgb(bg)
  local f = rgb(fg)
  local blend = function(i)
    local ret = (alpha * f[i] + ((1 - alpha) * b[i]))
    return math.floor(math.min(math.max(0, ret), 255) + 0.5)
  end
  return string.format('#%02x%02x%02x', blend(1), blend(2), blend(3))
end

local function is_hex_color(color)
  return type(color) == 'string' and color:match '^#%x%x%x%x%x%x$' ~= nil
end

local function channel_to_linear(channel)
  local value = channel / 255
  if value <= 0.03928 then
    return value / 12.92
  end
  return ((value + 0.055) / 1.055) ^ 2.4
end

local function color_luminance(color)
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  local lr = channel_to_linear(r)
  local lg = channel_to_linear(g)
  local lb = channel_to_linear(b)
  return 0.2126 * lr + 0.7152 * lg + 0.0722 * lb
end

local function cap_luminance(color, max_color)
  if not is_hex_color(color) or not is_hex_color(max_color) then
    return color
  end

  local max_luma = color_luminance(max_color)
  if color_luminance(color) <= max_luma then
    return color
  end

  local lo = 0
  local hi = 1
  local best = max_color

  for _ = 1, 12 do
    local mid = (lo + hi) / 2
    local candidate = M.blend(color, mid, max_color)
    if color_luminance(candidate) <= max_luma then
      best = candidate
      lo = mid
    else
      hi = mid
    end
  end

  return best
end

local function get_highlights(c, opts)
  local transparent = opts.transparent
  local blend = M.blend

  -- stylua: ignore
  local hl = {
    -- Base editor highlights
    Comment                     = { fg = c.comment, style = opts.styles.comments },
    ColorColumn                 = { bg = c.black },
    Conceal                     = { fg = c.fg_gutter },
    Cursor                      = { fg = c.bg, bg = c.fg },
    lCursor                     = { fg = c.bg, bg = c.fg },
    CursorIM                    = { fg = c.bg, bg = c.fg },
    CursorColumn                = { bg = c.bg_highlight },
    CursorLine                  = { bg = c.bg_highlight },
    Directory                   = { fg = c.fg_dark },
    DiffAdd                     = { bg = c.diff.add },
    DiffChange                  = { bg = c.diff.change },
    DiffDelete                  = { bg = c.diff.delete },
    DiffText                    = { bg = c.diff.text },
    EndOfBuffer                 = { fg = c.bg },
    ErrorMsg                    = { fg = c.error },
    VertSplit                   = { fg = c.border },
    WinSeparator                = { fg = c.border, bold = true },
    Folded                      = { fg = c.fg, bg = c.fg_gutter },
    FoldColumn                  = { bg = transparent and c.none or c.bg, fg = c.comment },
    SignColumn                  = { bg = transparent and c.none or c.bg, fg = c.fg_gutter },
    SignColumnSB                = { bg = c.bg_sidebar, fg = c.fg_gutter },
    Substitute                  = { bg = c.red, fg = c.black },
    LineNr                      = { fg = c.fg_gutter },
    CursorLineNr                = { fg = c.fg, bold = true },
    LineNrAbove                 = { fg = c.fg_gutter },
    LineNrBelow                 = { fg = c.fg_gutter },
    MatchParen                  = { fg = c.fg_dark, bold = true },
    ModeMsg                     = { fg = c.fg_dark, bold = true },
    MsgArea                     = { fg = c.fg },
    MoreMsg                     = { fg = c.fg },
    NonText                     = { fg = c.border },
    Normal                      = { fg = c.fg, bg = transparent and c.none or c.bg },
    NormalNC                    = { fg = c.fg, bg = transparent and c.none or opts.dim_inactive and c.bg_dark or c.bg },
    NormalSB                    = { fg = c.fg_sidebar, bg = c.bg_sidebar },
    NormalFloat                 = { fg = c.fg, bg = c.bg_float },
    FloatBorder                 = { fg = c.border_highlight, bg = c.bg_float },
    FloatTitle                  = { fg = c.border_highlight, bg = c.bg_float },
    Pmenu                       = { bg = c.bg_popup, fg = c.fg },
    PmenuMatch                  = { bg = c.bg_popup, fg = c.fg_dark },
    PmenuSel                    = { bg = blend(c.fg_gutter, 0.8, c.bg) },
    PmenuMatchSel               = { bg = blend(c.fg_gutter, 0.8, c.bg), fg = c.fg_dark },
    PmenuSbar                   = { bg = blend(c.bg_popup, 0.95, c.fg) },
    PmenuThumb                  = { bg = c.fg_gutter },
    Question                    = { fg = c.fg },
    QuickFixLine                = { bg = c.bg_visual, bold = true },
    Search                      = { bg = c.bg_search, fg = c.fg },
    IncSearch                   = { bg = c.orange, fg = c.black },
    CurSearch                   = 'IncSearch',
    SpecialKey                  = { fg = c.border },
    SpellBad                    = { sp = c.error, undercurl = true },
    SpellCap                    = { sp = c.warning, undercurl = true },
    SpellLocal                  = { sp = c.info, undercurl = true },
    SpellRare                   = { sp = c.hint, undercurl = true },
    StatusLine                  = { fg = c.fg_sidebar, bg = c.bg_statusline },
    StatusLineNC                = { fg = c.fg_gutter, bg = c.bg_statusline },
    TabLine                     = { bg = c.bg_statusline, fg = c.fg_gutter },
    TabLineFill                 = { bg = transparent and c.none or c.black },
    TabLineSel                  = { fg = c.black, bg = c.cyan2 },
    Title                       = { fg = c.fg_dark, bold = true },
    Visual                      = { bg = c.bg_visual },
    VisualNOS                   = { bg = c.bg_visual },
    WarningMsg                  = { fg = c.warning },
    Whitespace                  = { fg = c.fg_gutter },
    WildMenu                    = { bg = c.bg_visual },
    WinBar                      = 'StatusLine',
    WinBarNC                    = 'StatusLineNC',

    -- Syntax highlights
    Bold                        = { bold = true, fg = c.fg },
    Character                   = { fg = c.fg },
    Constant                    = { fg = c.fg },
    Debug                       = { fg = c.orange },
    Delimiter                   = 'Special',
    Error                       = { fg = c.error },
    Function                    = { fg = c.fg, style = opts.styles.functions },
    Identifier                  = { fg = c.fg, style = opts.styles.variables },
    Italic                      = { italic = true, fg = c.fg },
    Keyword                     = { fg = c.orange, style = opts.styles.keywords },
    Operator                    = { fg = c.fg },
    PreProc                     = { fg = c.fg },
    Special                     = { fg = c.fg },
    Statement                   = { fg = c.fg },
    String                      = { fg = c.cyan },
    Todo                        = { bg = c.todo, fg = c.bg },
    Experimental                = { bg = c.purple, fg = c.bg },
    Type                        = { fg = c.fg_dark },
    Underlined                  = { underline = true },
    debugBreakpoint             = { bg = blend(c.info, 0.1, c.bg), fg = c.info },
    debugPC                     = { bg = c.bg_sidebar },
    dosIniLabel                 = '@property',
    helpCommand                 = { bg = c.terminal_black, fg = c.blue },
    htmlH1                      = { fg = c.fg, bold = true },
    htmlH2                      = { fg = c.fg, bold = true },
    qfFileName                  = { fg = c.fg },
    qfLineNr                    = { fg = c.fg_gutter },
    Number                      = { fg = c.cyan },
    Float                       = { fg = c.cyan },
    Boolean                     = { fg = c.cyan },

    -- LSP
    LspReferenceText            = { bg = c.fg_gutter },
    LspReferenceRead            = { bg = c.fg_gutter },
    LspReferenceWrite           = { bg = c.fg_gutter },
    LspSignatureActiveParameter = { bg = blend(c.bg_visual, 0.4, c.bg), bold = true },
    LspCodeLens                 = { fg = c.comment },
    LspInlayHint                = { bg = c.bg_highlight, fg = c.comment },
    LspInfoBorder               = { fg = c.border_highlight, bg = c.bg_float },

    -- Diagnostics
    DiagnosticError             = { fg = c.error },
    DiagnosticWarn              = { fg = c.warning },
    DiagnosticInfo              = { fg = c.info },
    DiagnosticHint              = { fg = c.hint },
    DiagnosticUnnecessary       = { fg = c.terminal_black },
    DiagnosticVirtualTextError  = { bg = blend(c.error, 0.1, c.bg), fg = c.error },
    DiagnosticVirtualTextWarn   = { bg = blend(c.warning, 0.1, c.bg), fg = c.warning },
    DiagnosticVirtualTextInfo   = { bg = blend(c.info, 0.1, c.bg), fg = c.info },
    DiagnosticVirtualTextHint   = { bg = blend(c.hint, 0.1, c.bg), fg = c.hint },
    DiagnosticUnderlineError    = { undercurl = true, sp = c.error },
    DiagnosticUnderlineWarn     = { undercurl = true, sp = c.warning },
    DiagnosticUnderlineInfo     = { undercurl = true, sp = c.info },
    DiagnosticUnderlineHint     = { undercurl = true, sp = c.hint },

    -- Health
    healthError                 = { fg = c.error },
    healthSuccess               = { fg = c.green },
    healthWarning               = { fg = c.warning },

    -- Diff
    diffAdded                   = { bg = c.diff.add, fg = c.git.add },
    diffRemoved                 = { bg = c.diff.delete, fg = c.git.delete },
    diffChanged                 = { bg = c.diff.change, fg = c.git.change },
    diffOldFile                 = { fg = c.cyan, bg = c.diff.delete },
    diffNewFile                 = { fg = c.cyan, bg = c.diff.add },
    diffFile                    = { fg = c.cyan },
    diffLine                    = { fg = c.comment },
    diffIndexLine               = { fg = c.purple },
    helpExample                 = { fg = c.comment },

    -- Treesitter captures
    ['@variable']               = { fg = c.fg },
    ['@variable.member']        = { fg = c.fg },
    ['@variable.builtin']       = { fg = c.fg },
    ['@property']               = { fg = c.fg },
    ['@field']                  = { fg = c.fg },
    ['@function']               = { fg = c.fg, style = opts.styles.functions },
    ['@function.call']          = { fg = c.fg },
    ['@function.builtin']       = { fg = c.fg_dark },
    ['@keyword']                = { fg = c.orange, style = opts.styles.keywords },
    ['@operator']               = { fg = c.fg },
    ['@punctuation']            = { fg = c.fg },

    -- LSP semantic tokens
    ['@lsp.type.boolean']                      = '@boolean',
    ['@lsp.type.builtinType']                  = '@type.builtin',
    ['@lsp.type.comment']                      = '@comment',
    ['@lsp.type.decorator']                    = '@attribute',
    ['@lsp.type.deriveHelper']                 = '@attribute',
    ['@lsp.type.enum']                         = '@type',
    ['@lsp.type.enumMember']                   = { fg = c.cyan },
    ['@lsp.type.escapeSequence']               = '@string.escape',
    ['@lsp.type.formatSpecifier']              = '@markup.list',
    ['@lsp.type.generic']                      = '@variable',
    ['@lsp.type.interface']                    = { fg = c.cyan },
    ['@lsp.type.keyword']                      = '@keyword',
    ['@lsp.type.lifetime']                     = '@keyword.storage',
    ['@lsp.type.namespace']                    = '@module',
    ['@lsp.type.namespace.python']             = '@variable',
    ['@lsp.type.number']                       = '@number',
    ['@lsp.type.operator']                     = '@operator',
    ['@lsp.type.parameter']                    = '@variable.parameter',
    ['@lsp.type.property']                     = '@property',
    ['@lsp.type.selfKeyword']                  = '@variable.builtin',
    ['@lsp.type.selfTypeKeyword']              = '@variable.builtin',
    ['@lsp.type.string']                       = '@string',
    ['@lsp.type.typeAlias']                    = '@type.definition',
    ['@lsp.type.unresolvedReference']          = { undercurl = true, sp = c.error },
    ['@lsp.type.variable']                     = {},
    ['@lsp.typemod.class.defaultLibrary']      = '@type.builtin',
    ['@lsp.typemod.enum.defaultLibrary']       = '@type.builtin',
    ['@lsp.typemod.enumMember.defaultLibrary'] = '@constant.builtin',
    ['@lsp.typemod.function.defaultLibrary']   = '@function.builtin',
    ['@lsp.typemod.keyword.async']             = '@keyword.coroutine',
    ['@lsp.typemod.keyword.injected']          = '@keyword',
    ['@lsp.typemod.macro.defaultLibrary']      = '@function.builtin',
    ['@lsp.typemod.method.defaultLibrary']     = '@function.builtin',
    ['@lsp.typemod.operator.injected']         = '@operator',
    ['@lsp.typemod.string.injected']           = '@string',
    ['@lsp.typemod.struct.defaultLibrary']     = '@type.builtin',
    ['@lsp.typemod.type.defaultLibrary']       = { fg = c.cyan },
    ['@lsp.typemod.typeAlias.defaultLibrary']  = { fg = c.cyan },
    ['@lsp.typemod.variable.callable']         = '@function',
    ['@lsp.typemod.variable.defaultLibrary']   = '@variable.builtin',
    ['@lsp.typemod.variable.injected']         = '@variable',
    ['@lsp.typemod.variable.static']           = '@constant',

    -- Completion item kinds
    CmpItemKindDefault          = { fg = c.fg },
    CmpItemKindClass            = { fg = c.fg_dark },
    CmpItemKindColor            = { fg = c.cyan },
    CmpItemKindConstant         = { fg = c.fg },
    CmpItemKindConstructor      = { fg = c.fg },
    CmpItemKindEnum             = { fg = c.fg_dark },
    CmpItemKindEnumMember       = { fg = c.fg },
    CmpItemKindEvent            = { fg = c.fg },
    CmpItemKindField            = { fg = c.fg },
    CmpItemKindFile             = { fg = c.fg },
    CmpItemKindFolder           = { fg = c.fg_dark },
    CmpItemKindFunction         = { fg = c.fg },
    CmpItemKindInterface        = { fg = c.fg },
    CmpItemKindKeyword          = { fg = c.fg_dark },
    CmpItemKindMethod           = { fg = c.fg },
    CmpItemKindModule           = { fg = c.fg_dark },
    CmpItemKindOperator         = { fg = c.fg },
    CmpItemKindProperty         = { fg = c.fg },
    CmpItemKindReference        = { fg = c.fg },
    CmpItemKindSnippet          = { fg = c.fg },
    CmpItemKindStruct           = { fg = c.fg },
    CmpItemKindText             = { fg = c.fg },
    CmpItemKindTypeParameter    = { fg = c.fg },
    CmpItemKindUnit             = { fg = c.fg },
    CmpItemKindValue            = { fg = c.fg },
    CmpItemKindVariable         = { fg = c.fg },

    -- Indent Blankline
    IblIndent                   = { fg = c.border, nocombine = true },
    IblScope                    = { fg = c.cyan2, nocombine = true },

    -- Which-key
    WhichKey                    = { fg = c.cyan },
    WhichKeyGroup               = { fg = c.fg },
    WhichKeyDesc                = { fg = c.fg_dark },
    WhichKeySeparator           = { fg = c.comment },
    WhichKeyValue               = { fg = c.fg_gutter },

    -- Mini
    MiniIndentscopeSymbol       = { fg = c.cyan, nocombine = true },
    MiniStatuslineFilename      = { fg = c.fg, bg = c.bg_statusline },
    MiniStatuslineInactive      = { fg = c.comment, bg = c.bg_statusline },
    MiniCursorword              = { bg = c.fg_gutter },
  }

  -- Markdown heading colors
  for i, color in ipairs(c.rainbow) do
    hl['@markup.heading.' .. i .. '.markdown'] = { fg = color, bold = true, bg = blend(color, 0.1, c.bg) }
  end

  return hl
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

function M.extend(opts)
  return opts and vim.tbl_deep_extend('force', {}, M.options or M.defaults, opts) or (M.options or M.defaults)
end

function M.load(opts)
  opts = M.extend(opts)

  local p = vim.deepcopy(palette)
  local blend = M.blend

  p.bg_sidebar = opts.styles.sidebars == 'transparent' and p.none
    or opts.styles.sidebars == 'dark' and p.bg_dark
    or p.bg
  p.bg_float = opts.styles.floats == 'transparent' and p.none
    or opts.styles.floats == 'dark' and p.bg_dark
    or p.bg

  opts.on_colors(p)

  local c = p
  local hl = get_highlights(c, opts)

  opts.on_highlights(hl, c)

  for _, h in pairs(hl) do
    if type(h) == 'table' and type(h.style) == 'table' then
      for k, v in pairs(h.style) do
        h[k] = v
      end
      h.style = nil
    end

    if type(h) == 'table' and is_hex_color(h.fg) then
      h.fg = cap_luminance(h.fg, c.fg)
    end
  end

  if vim.g.colors_name then
    vim.cmd 'hi clear'
  end

  vim.o.termguicolors = true
  vim.g.colors_name = 'bonsai'

  for group, def in pairs(hl) do
    def = type(def) == 'string' and { link = def } or def
    vim.api.nvim_set_hl(0, group, def)
  end

  if opts.terminal_colors then
    -- stylua: ignore start
    vim.g.terminal_color_0  = c.black
    vim.g.terminal_color_1  = c.red
    vim.g.terminal_color_2  = c.green
    vim.g.terminal_color_3  = c.yellow
    vim.g.terminal_color_4  = c.blue
    vim.g.terminal_color_5  = c.purple1
    vim.g.terminal_color_6  = c.cyan
    vim.g.terminal_color_7  = c.fg_dark
    vim.g.terminal_color_8  = c.terminal_black
    vim.g.terminal_color_9  = c.magenta
    vim.g.terminal_color_10 = c.green2
    vim.g.terminal_color_11 = blend(c.yellow, 0.8, c.fg)
    vim.g.terminal_color_12 = c.blue2
    vim.g.terminal_color_13 = c.purple2
    vim.g.terminal_color_14 = c.cyan1
    vim.g.terminal_color_15 = c.fg
    -- stylua: ignore end
  end
end

return M
