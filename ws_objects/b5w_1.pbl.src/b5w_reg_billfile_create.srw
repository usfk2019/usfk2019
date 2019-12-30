$PBExportHeader$b5w_reg_billfile_create.srw
$PBExportComments$[ohj] 청구file 생성
forward
global type b5w_reg_billfile_create from w_a_inq_m
end type
type cb_1 from commandbutton within b5w_reg_billfile_create
end type
end forward

global type b5w_reg_billfile_create from w_a_inq_m
integer width = 3113
integer height = 1680
cb_1 cb_1
end type
global b5w_reg_billfile_create b5w_reg_billfile_create

on b5w_reg_billfile_create.create
int iCurrent
call super::create
this.cb_1=create cb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_1
end on

on b5w_reg_billfile_create.destroy
call super::destroy
destroy(this.cb_1)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	b1w_reg_billfile_create
	Desc.	: 	청구서파일 생성
	Ver.	:	1.0
	Date	: 	2004.02.23
	Programer : oh hye jin
--------------------------------------------------------------------------*/

end event

event ue_ok();call super::ue_ok;String ls_where, ls_ref_desc, ls_temp, ls_result[], ls_where_1, ls_new
Long   ll_row, li_i

//
//is_bill_type = Trim(dw_cond.object.bill_type[1])
//
//If IsNull(is_bill_type) Then is_bill_type = ""
//
//If is_bill_type = "" Then
//	f_msg_info(200, Title, "Bill Type")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("bill_type")
//	Return 
//End If
//
//ls_where = ""
//If ls_where <> "" Then ls_where += " And "
//ls_where += " INVF_TYPE = '" + is_bill_type + "' "

//ls_ref_desc = ""
//ls_temp = fs_get_control("B0","A100", ls_ref_desc)
//If ls_temp <> "" Then
//   fi_cut_string(ls_temp, ";" , ls_result[])
//End if
//
//ls_where_1 = ""
//For li_i = 1 To UpperBound(ls_result[])
//	If ls_where_1 <> "" Then ls_where_1 += " Or "
//	ls_where_1 += "A.method = '" + ls_result[li_i] + "'"
//Next
//
//If ls_where <> "" Then
//	If ls_where_1 <> "" Then ls_where = ls_where + " And ( " + ls_where_1 + " ) "  
//Else
//	ls_where = ls_where_1
//End if

//dw_master.SetRedraw(False)
//
//dw_master.is_where = ls_where

//Retrieve
ll_row = dw_detail.Retrieve()

dw_detail.SetRedraw(True)
dw_detail.SetFocus()
dw_detail.SelectRow(0, False)
dw_detail.ScrollToRow(1)
dw_detail.SelectRow(1, True)
	
If ll_row = 0 Then 
	f_msg_info(1000, Title, "")

ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return

End If


	
end event

type dw_cond from w_a_inq_m`dw_cond within b5w_reg_billfile_create
boolean visible = false
end type

type p_ok from w_a_inq_m`p_ok within b5w_reg_billfile_create
integer x = 1760
integer y = 36
end type

type p_close from w_a_inq_m`p_close within b5w_reg_billfile_create
integer x = 2062
integer y = 36
end type

type gb_cond from w_a_inq_m`gb_cond within b5w_reg_billfile_create
boolean visible = false
end type

type dw_detail from w_a_inq_m`dw_detail within b5w_reg_billfile_create
integer y = 160
string dataobject = "b5dw_cnd_reg_billfile_create"
end type

type cb_1 from commandbutton within b5w_reg_billfile_create
integer x = 2423
integer y = 36
integer width = 613
integer height = 92
integer taborder = 20
boolean bringtotop = true
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS UI Gothic"
string text = "Bill File Creation"
end type

event clicked;iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "Bill file Creation"
iu_cust_msg.is_grp_name = "Bill file Creation"
iu_cust_msg.idw_data[1] = dw_detail

OpenWithParm(b5w_inq_billfile_create_popup, iu_cust_msg)

end event

