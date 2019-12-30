$PBExportHeader$w_msg_wait.srw
$PBExportComments$대기 메세지 윈도우
forward
global type w_msg_wait from window
end type
type hpb_progress from hprogressbar within w_msg_wait
end type
type dw_1 from u_d_external within w_msg_wait
end type
end forward

global type w_msg_wait from window
integer x = 1111
integer y = 876
integer width = 1248
integer height = 632
boolean titlebar = true
string title = "Untitled"
windowtype windowtype = popup!
long backcolor = 27306400
hpb_progress hpb_progress
dw_1 dw_1
end type
global w_msg_wait w_msg_wait

forward prototypes
public subroutine wf_progress_step ()
public subroutine wf_progress_position (long al_position)
public subroutine wf_progress_init (long al_minposition, long al_maxposition, long al_position, long al_setstep)
end prototypes

public subroutine wf_progress_step ();hpb_progress.StepIt()

end subroutine

public subroutine wf_progress_position (long al_position);hpb_progress.Position = al_position

end subroutine

public subroutine wf_progress_init (long al_minposition, long al_maxposition, long al_position, long al_setstep);If IsNull(al_minposition) Then al_minposition = 0
If IsNull(al_maxposition) Then al_maxposition = 100
If IsNull(al_position) Then al_position = 0
If IsNull(al_setstep) Then al_setstep = 1

w_msg_wait.hpb_progress.Visible = True
w_msg_wait.hpb_progress.MinPosition = al_minposition
w_msg_wait.hpb_progress.MaxPosition = al_maxposition
w_msg_wait.hpb_progress.Position = al_position
w_msg_wait.hpb_progress.SetStep = al_setstep

end subroutine

on w_msg_wait.create
this.hpb_progress=create hpb_progress
this.dw_1=create dw_1
this.Control[]={this.hpb_progress,&
this.dw_1}
end on

on w_msg_wait.destroy
destroy(this.hpb_progress)
destroy(this.dw_1)
end on

event open;hpb_progress.Visible = False

end event

type hpb_progress from hprogressbar within w_msg_wait
integer x = 73
integer y = 448
integer width = 1065
integer height = 64
boolean bringtotop = true
unsignedinteger maxposition = 100
integer setstep = 1
boolean smoothscroll = true
end type

type dw_1 from u_d_external within w_msg_wait
integer x = 73
integer y = 64
integer width = 1065
integer height = 356
string dataobject = "d_msg_wait"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

