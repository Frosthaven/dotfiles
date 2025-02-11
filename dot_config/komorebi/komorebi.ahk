#Requires AutoHotkey v2.0.2
#SingleInstance Force

Komorebic(cmd) {
    RunWait(format("komorebic.exe {}", cmd), , "Hide")
}

init() {
    Run "komorebic alt-focus-hack enable", , "Hide"
    Run "komorebic window-hiding-behavior cloak", , "Hide"
    Run "komorebic cross-monitor-move-behavior insert", , "Hide"
    Run "komorebic watch-configuration enable", , "Hide"
    Run "komorebic ensure-named-workspaces 1 1 2 3 4", , "Hide"
    Run "komorebic workspace-layout 1 0 ultrawide-vertical-stack", , "Hide"
    Run "komorebic workspace-layout 1 1 ultrawide-vertical-stack", , "Hide"
    Run "komorebic workspace-layout 1 2 ultrawide-vertical-stack", , "Hide"
    Run "komorebic workspace-layout 1 3 ultrawide-vertical-stack", , "Hide"
    Run "komorebic animation enable", , "Hide"
}

init()

; Focus windows should be meta + alt + hjkl/arrow keys
; ! = alt,
; + = shift,
; ^ = ctrl,
; # = win

; DISABLERS *******************************************************************
; *****************************************************************************

; Disable the default Windows keymaps for win+ctrl+arrow keys
 #Left::return
 #Right::return
 #Up::return
 #Down::return

; GLOBALS *********************************************************************
; *****************************************************************************

; ctrl+q to close the current window
^q::Komorebic("close")

; f11 to toggle maximize
f11::Komorebic("toggle-maximize")

;#m::Komorebic("minimize")

; FOCUS CHANGE KEYMAPS ********************************************************
; *****************************************************************************

; window panes **********************************

; vim-style
!#h::Komorebic("focus left")
!#j::Komorebic("focus down")
!#k::Komorebic("focus up")
!#l::Komorebic("focus right")

; arrow-style
!#Left::Komorebic("focus left")
!#Down::Komorebic("focus down")
!#Up::Komorebic("focus up")
!#Right::Komorebic("focus right")

; workspaces ************************************

#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")

; MOVEMENT KEYMAPS ************************************************************
; *****************************************************************************

; window panes **********************************

; vim-style
#+h::Komorebic("move left")
#+j::Komorebic("move down")
#+k::Komorebic("move up")
#+l::Komorebic("move right")

; arrow-style
#+Left::Komorebic("move left")
#+Down::Komorebic("move down")
#+Up::Komorebic("move up")
#+Right::Komorebic("move right")

; workspaces ************************************

#+1::Komorebic("move-to-workspace 0")
#+2::Komorebic("move-to-workspace 1")
#+3::Komorebic("move-to-workspace 2")
#+4::Komorebic("move-to-workspace 3")

; JOIN KEYMAPS ****************************************************************
; *****************************************************************************

; vim-style
;#^h::Komorebic("stack left")
;#^j::Komorebic("stack down")
;#^k::Komorebic("stack up")
;#^l::Komorebic("stack right")

; arrow-style
;#^Left::Komorebic("stack left")
;#^Down::Komorebic("stack down")
;#^Up::Komorebic("stack up")
;#^Right::Komorebic("stack right")

; STACK KEYMAPS ***************************************************************
; *****************************************************************************

; vim-style
;#^h::Komorebic("stack left")
;#^j::Komorebic("stack down")
;#^k::Komorebic("stack up")
;#^l::Komorebic("stack right")

; arrow-style
;#^Left::Komorebic("stack left")
;#^Down::Komorebic("stack down")
;#^Up::Komorebic("stack up")
;#^Right::Komorebic("stack right")

; RESIZE KEYMAPS **************************************************************
; *****************************************************************************

; vim-style
!+#h::Komorebic("resize-axis horizontal decrease")
!+#j::Komorebic("resize-axis vertical decrease")
!+#k::Komorebic("resize-axis vertical increase")
!+#l::Komorebic("resize-axis horizontal increase")

; arrow-style
!+#Left::Komorebic("resize-axis horizontal decrease")
!+#Down::Komorebic("resize-axis vertical decrease")
!+#Up::Komorebic("resize-axis vertical increase")
!+#Right::Komorebic("resize-axis horizontal increase")

; Manipulate windows
;!t::Komorebic("toggle-float")
;!f::Komorebic("toggle-monocle")

; Window manager options
;!+r::Komorebic("retile")
;!p::Komorebic("toggle-pause")

; Layouts
;!x::Komorebic("flip-layout horizontal")
;!y::Komorebic("flip-layout vertical")

