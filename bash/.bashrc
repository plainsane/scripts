PS1="\n\$(RET=\"\$?\"; if [ \"\$RET\" != \"0\" ] ; then  echo -en \"\[\033[41;30m\]\" ; else echo -en \"\[\033[01;33m\]\"; fi ; echo -en \"Last Return Code: \$RET @ \" ; date \"+%Y/%m/%d %H:%M:%S\")\[\033[00m\]\n\[\033[01;32m\]\u@\h\${debian_chroot:+(\$debian_chroot)}\[\033[01;34m\] \w \$\[\033[00m\] "

export EDITOR=/usr/bin/vim
#setxkbmap -option terminate:ctrl_alt_bksp
stty stop ^X
