$PBExportHeader$w_reg_code_detail1_term.srw
$PBExportComments$code 등록 ( from w_a_reg_m_m)
forward
global type w_reg_code_detail1_term from w_a_reg_m_m
end type
end forward

global type w_reg_code_detail1_term from w_a_reg_m_m
integer width = 3333
integer height = 2256
end type
global w_reg_code_detail1_term w_reg_code_detail1_term

type variables

TRANSACTION SQLCA_TERM

end variables

on w_reg_code_detail1_term.create
call super::create
end on

on w_reg_code_detail1_term.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;Long ll_row
Int li_return
String ls_code,ls_desc,ls_where

dw_master.settransobject(SQLCA_TERM)
dw_detail.settransobject(SQLCA_TERM)

ls_code = dw_cond.Object.sle_code[1]

If ls_code <> '' and Not IsNull(ls_code) Then
	ls_where = ls_where + "grcode like '" + ls_code + "%" + "'"
End If

ls_desc = dw_cond.Object.sle_desc[1]

If ls_desc <> '' and Not IsNull(ls_desc) Then
	If ls_where <> "" Then
		ls_where = ls_where + " and "
	End If
	ls_where = ls_where + "grcodenm like '%" + ls_desc + "%" + "'"
End If

dw_master.is_where = ls_where

ll_row = dw_master.Retrieve()

If ll_row <= 0 Then
	Beep(1)
	
	If ll_row = 0 Then
		f_msg_usr_err(1100,This.Title,"CODE OR DESC")
	ElseIf ll_row < 0 Then
		f_msg_usr_err(2100,This.Title,"DATAWINDOW RETRIEVE()")
	End if
	
	dw_cond.SetFocus()
	dw_cond.SetColumn("sle_code")
	Return
End if


end event

event ue_extra_insert;dw_detail.Object.grcode[al_insert_row] = &
 dw_master.Object.grcode[dw_master.GetSelectedRow(0)]

dw_detail.SetItemStatus(al_insert_row, 0, Primary!, NotModified!)
Return 0
end event

event open;call super::open;

//TRANSACTION SQLCA_TERM
SQLCA_TERM = CREATE TRANSACTION 
SQLCA_TERM.DBMS  = "O84 ORACLE 8.0.4"
SQLCA_TERM.SERVERNAME = SQLCA.ServerName
SQLCA_TERM.LogId = "termcust"
SQLCA_TERM.LOGPASS = "termcust123"
SQLCA_TERM.AUTOCOMMIT = FALSE
CONNECT USING SQLCA_TERM;

IF SQLCA_TERM.SQLCODE < 0 THEN
	DISCONNECT USING SQLCA_TERM;
	DESTROY SQLCA_TERM;
	MESSAGEBOX("SQLCA_TERM CONNECT ERROR", "연결에 실패하였습니다. 관리자에게 문의하시기 바랍니다")
	RETURN
END IF



dw_cond.object.sle_code[1] = 'TERM'
end event

type dw_cond from w_a_reg_m_m`dw_cond within w_reg_code_detail1_term
integer x = 59
integer y = 88
integer width = 2126
integer height = 132
string dataobject = "d_cnd_code_desc_term"
boolean vscrollbar = false
end type

type p_ok from w_a_reg_m_m`p_ok within w_reg_code_detail1_term
integer x = 2309
integer y = 44
end type

type p_close from w_a_reg_m_m`p_close within w_reg_code_detail1_term
integer x = 2606
integer y = 44
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within w_reg_code_detail1_term
integer width = 2194
integer height = 260
end type

type dw_master from w_a_reg_m_m`dw_master within w_reg_code_detail1_term
integer y = 280
integer width = 2999
integer height = 496
string dataobject = "d_inq_group_code1_term"
end type

event dw_master::constructor;call super::constructor;

dwobject ldwo_sort

ldwo_sort = This.Object.grcode_t

This.uf_init(ldwo_sort)//,"a",RGB(255,255,255))
end event

type dw_detail from w_a_reg_m_m`dw_detail within w_reg_code_detail1_term
integer y = 820
integer width = 2999
integer height = 936
string dataobject = "d_reg_code_detail1_term"
end type

event ue_retrieve;String ls_grcode

ls_grcode = dw_master.Object.grcode[al_select_row]

dw_detail.is_where = "grcode  = '" + ls_grcode + "'"

If dw_detail.Retrieve() < 0 Then
	Return -1
End If

Return 0

end event

event dw_detail::constructor;call super::constructor;ib_downarrow = True


end event

type p_insert from w_a_reg_m_m`p_insert within w_reg_code_detail1_term
integer x = 37
integer y = 1784
end type

type p_delete from w_a_reg_m_m`p_delete within w_reg_code_detail1_term
integer x = 329
integer y = 1784
end type

type p_save from w_a_reg_m_m`p_save within w_reg_code_detail1_term
integer x = 631
integer y = 1784
end type

type p_reset from w_a_reg_m_m`p_reset within w_reg_code_detail1_term
integer x = 2112
integer y = 2092
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within w_reg_code_detail1_term
integer y = 780
end type

