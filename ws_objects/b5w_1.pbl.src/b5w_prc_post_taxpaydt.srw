$PBExportHeader$b5w_prc_post_taxpaydt.srw
$PBExportComments$[jwlee] 후불 세금계산서 입금일 update
forward
global type b5w_prc_post_taxpaydt from w_a_prc
end type
type st_1 from statictext within b5w_prc_post_taxpaydt
end type
end forward

global type b5w_prc_post_taxpaydt from w_a_prc
integer height = 1132
st_1 st_1
end type
global b5w_prc_post_taxpaydt b5w_prc_post_taxpaydt

type variables

end variables

on b5w_prc_post_taxpaydt.create
int iCurrent
call super::create
this.st_1=create st_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_1
end on

on b5w_prc_post_taxpaydt.destroy
call super::destroy
destroy(this.st_1)
end on

event type integer ue_process();
String ls_errmsg
Long ll_return
double lb_count

ll_return = -1
ls_errmsg = space(800)

//처리부분...
SQLCA.B5W_POST_TAXPAYDT(ll_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ll_return = -1
ElseIf ll_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If

If ll_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = "Count: " + String(lb_count, "#,##0") + " 건"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;
Return 0
end event

event open;call super::open;
p_ok.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within b5w_prc_post_taxpaydt
integer x = 1449
integer y = 36
end type

type dw_input from w_a_prc`dw_input within b5w_prc_post_taxpaydt
boolean visible = false
integer x = 64
integer y = 44
integer width = 1230
integer height = 148
boolean hscrollbar = false
boolean vscrollbar = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_post_taxpaydt
integer y = 744
integer width = 1856
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_post_taxpaydt
integer y = 280
integer width = 1856
end type

type ln_up from w_a_prc`ln_up within b5w_prc_post_taxpaydt
integer beginy = 264
integer endx = 1838
integer endy = 264
end type

type ln_down from w_a_prc`ln_down within b5w_prc_post_taxpaydt
integer beginy = 1024
integer endx = 1838
integer endy = 1024
end type

type p_close from w_a_prc`p_close within b5w_prc_post_taxpaydt
integer x = 1449
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_post_taxpaydt
integer width = 1307
integer height = 232
end type

type st_1 from statictext within b5w_prc_post_taxpaydt
integer x = 91
integer y = 104
integer width = 1230
integer height = 64
boolean bringtotop = true
integer textsize = -10
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
long textcolor = 33554432
long backcolor = 29478337
string text = "후불 세금계산서 입금일을 Update합니다."
boolean focusrectangle = false
end type

