{
  config,
  username,
  ...
}: {
  # Limit XPS-specific treesitter grammars to a stable subset.
  # The nixpkgs commit needed for Linux 7.0 currently trips over the upstream Elsa parser.
  home-manager.users.${username}.programs.nixvim.plugins.treesitter.grammarPackages =
    with config.home-manager.users.${username}.programs.nixvim.plugins.treesitter.package.builtGrammars; [
      bash
      c
      cpp
      css
      diff
      dockerfile
      git_config
      gitcommit
      gitignore
      go
      gomod
      gosum
      html
      hyprlang
      javascript
      jsdoc
      json
      json5
      jsonnet
      lua
      markdown
      markdown_inline
      nix
      python
      query
      regex
      rust
      scss
      sql
      toml
      tsx
      typescript
      typst
      vim
      vimdoc
      xml
      yaml
      zig
    ];
}
