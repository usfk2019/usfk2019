$PBExportHeader$w_base.srw
$PBExportComments$윈도우의 최상위 Ancestor
forward
global type w_base from window
end type
end forward

global type w_base from window
integer width = 3109
integer height = 1980
boolean titlebar = true
string title = "Untitled"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
boolean resizable = true
windowstate windowstate = maximized!
long backcolor = 29478337
end type
global w_base w_base

type variables
Private :
 //메세지 객체에 있는 ii_pgm_index를 저장할 변수
 Int ii_pgm_index

Protected :
 //메세지 전달 객체
 u_cust_a_msg iu_cust_msg

Public :
 //Default Event
 String is_default = "ue_ok"

 //Cancel Event
String is_close = "ue_close"

//Window Resize
u_cust_w_resize iu_cust_w_resize

end variables

on w_base.create
end on

on w_base.destroy
end on

event open;Int li_i
String ls_title

iu_cust_msg = Create u_cust_a_msg

iu_cust_msg = Message.PowerObjectParm

//윈도우 Title 설정
//This.Title = iu_cust_msg.is_grp_name + "(" + iu_cust_msg.is_pgm_name + ")"

//윈도우 Title 설정
This.Title =  iu_cust_msg.is_pgm_name 

//프로그램 관리 Queue에 저장 & 저장할 Index를 결정
For li_i = 1 To gi_max_win_no
	If gs_pgm_id[li_i] = "" Then
		ii_pgm_index = li_i
		gs_pgm_id[li_i] = iu_cust_msg.is_pgm_id
		Exit
	End If
Next

//열인 윈도우 갯수 증가
gi_open_win_no ++

iu_cust_w_resize = Create u_cust_w_resize

end event

event key;Choose Case key
	Case KeyEnter!, KeyTab!
		This.TriggerEvent(is_default)
	Case KeyEscape!
		This.TriggerEvent(is_close)
	Case KeyF1!    //Help을 뛰우기 위해
		fs_show_help(gs_pgm_id[gi_open_win_no])
End Choose

end event

event close;//프로그램을 삭제
IF ii_pgm_index > 0 then
	gs_pgm_id[ii_pgm_index] = ""
END IF

//열린 윈도우 갯수 감소
gi_open_win_no --

Destroy iu_cust_msg

If gi_open_win_no < 1 Then
	w_mdi_main.st_resize.Show()
	w_mdi_main.tv_menu.Show()
	m_mdi_main.ib_visible = True
End If	

Destroy(iu_cust_w_resize)

end event

