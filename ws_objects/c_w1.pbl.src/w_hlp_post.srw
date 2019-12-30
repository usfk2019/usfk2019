$PBExportHeader$w_hlp_post.srw
$PBExportComments$[ceusee] 우편번호
forward
global type w_hlp_post from w_a_hlp
end type
end forward

global type w_hlp_post from w_a_hlp
integer width = 2802
integer height = 2004
end type
global w_hlp_post w_hlp_post

event ue_find;call super::ue_find;String ls_where
String ls_hpost, ls_haddr
Long ll_row

dw_cond.AcceptText()

ls_where = ""
ls_hpost = Trim(dw_cond.Object.hpost[1])
If IsNull(ls_hpost) Then ls_hpost = ""
ls_haddr = Trim(dw_cond.Object.haddr[1])
If IsNull(ls_haddr) Then ls_haddr = ""


If ls_hpost = "" and ls_haddr = "" Then
	f_msg_usr_err(200, This.Title, "우편번호 혹은 동/면/읍")
	dw_cond.SetFocus()
	dw_cond.SetColumn("haddr")
	Return
End If

If ls_hpost <> ""Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "code like '" + ls_hpost + "%'"
End If

If ls_haddr <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "codenm like '%" + ls_haddr + "%'"
End If

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If


end event

event ue_extra_ok_with_return;call super::ue_extra_ok_with_return;iu_cust_help.is_data[1] = Trim(dw_hlp.Object.code[al_selrow])
iu_cust_help.is_data[2] = Trim(dw_hlp.Object.codenm[al_selrow])
iu_cust_help.is_data[3] = Trim(dw_hlp.Object.codenm2[al_selrow])

iu_cust_help.ib_data[1] = True

end event

event ue_close;call super::ue_close;//iu_cust_help.ib_data[1] = FALSE
//Close(This)
end event

event open;call super::open;/*--------------------------------------------------------------------
	Name	: 	w_hlp_post
	Desc.	:	우편번호
	Ver.	: 	1.0
	Date.	: 	2002.10.09
	Programer : Choi Bo Ra
----------------------------------------------------------------------*/
This.Title = "우편번호"

end event

on w_hlp_post.create
call super::create
end on

on w_hlp_post.destroy
call super::destroy
end on

type p_1 from w_a_hlp`p_1 within w_hlp_post
integer x = 1906
boolean originalsize = false
end type

type dw_cond from w_a_hlp`dw_cond within w_hlp_post
integer x = 41
integer y = 64
integer width = 1737
integer height = 212
string dataobject = "d_cnd_hlp_post"
end type

type p_ok from w_a_hlp`p_ok within w_hlp_post
integer x = 2194
end type

type p_close from w_a_hlp`p_close within w_hlp_post
integer x = 2487
end type

type gb_cond from w_a_hlp`gb_cond within w_hlp_post
integer x = 23
integer y = 12
integer width = 1833
integer height = 284
end type

type dw_hlp from w_a_hlp`dw_hlp within w_hlp_post
integer x = 23
integer y = 316
integer width = 2743
integer height = 1560
string dataobject = "d_hlp_post"
end type

event dw_hlp::constructor;call super::constructor;DWObject ldwo_sort

ldwo_sort = This.Object.code_t
uf_init(ldwo_sort)
end event

