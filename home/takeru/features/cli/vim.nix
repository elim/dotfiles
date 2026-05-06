{ ... }:

{
  programs.vim = {
    enable = true;

    extraConfig = ''
      " http://www.stripey.com/vim/vimrc.html
      if has('syntax') && (&t_Co > 2)
        syntax on
      endif

      set fileencoding=japan
      set fileencodings=cp932,utf-8,iso-2022-jp,euc-jp,ucs2le,ucs-2
      set number
      set ignorecase
      set smartindent
      set hidden
      set backspace=2
      set showmatch
      set notitle
      set paste
    '';
  };
}
