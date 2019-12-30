$PBExportHeader$b1w_hlp_contractmst_v20.srw
$PBExportComments$[parkkh] Help 계약SEQ
forward
global type b1w_hlp_contractmst_v20 from w_a_hlp
end type
end forward

global type b1w_hlp_contractmst_v20 from w_a_hlp
integer width = 4421
integer height = 1688
end type
global b1w_hlp_contractmst_v20 b1w_hlp_contractmst_v20

type variables
String is_status
end variables

on b1w_hlp_contractmst_v20.create
call super::create
end on

on b1w_hlp_contractmst_v20.destroy
call super::destroy
end on

event ue_find();call super::ue_find;//조회
String ls_customerid, ls_customernm, ls_where, ls_validkey
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
ls_customernm = Trim(dw_cond.object.customernm[1])
ls_validkey = Trim(dw_cond.object.validkey[1])

If IsNull(ls_customerid) Then ls_customerid = ""
If IsNull(ls_customernm) Then ls_customernm = ""
If IsNull(ls_validkey) Then ls_validkey = ""

ls_where = ""
If ls_customerid <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "con.customerid like '" + ls_customerid + "%' "
	
End If

If ls_customernm <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "Upper(cus.customernm) like '%" + Upper(ls_customernm) + "%' "
End If

If ls_validkey <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "val.validkey like '" + ls_validkey + "%' "
End If

If ls_where <> "" Then ls_where += " And "
ls_where += "con.status = '" + is_status + "' "

dw_hlp.is_where = ls_where
ll_row = dw_hlp.Retrieve()
If ll_row = 0 then
	f_msg_info(1000, Title, "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
End If
end event

event open;call super::open;This.Title = "Help 계약 SEQ ID"

String ls_ref_desc

ls_ref_desc = ""
is_status = fs_get_control("B0", "P223", ls_ref_desc)    //개통상태

end event

event ue_close();call super::ue_close;Close(This)
end event

event ue_extra_ok_with_return;iu_cust_help.ib_data[1] = True
iu_cust_help.is_data[1] = string(dw_hlp.Object.contractseq[al_selrow])		//contractseq
iu_cust_help.is_data[2] = string(dw_hlp.Object.validkey[al_selrow])		//validkey
end event

type p_1 from w_a_hlp`p_1 within b1w_hlp_contractmst_v20
integer x = 1385
integer y = 44
end type

type dw_cond from w_a_hlp`dw_cond within b1w_hlp_contractmst_v20
integer x = 46
integer y = 44
integer width = 1221
integer height = 300
string dataobject = "b1dw_cnd_hlp_contractmst"
boolean livescroll = false
end type

type p_ok from w_a_hlp`p_ok within b1w_hlp_contractmst_v20
integer x = 1682
integer y = 44
end type

type p_close from w_a_hlp`p_close within b1w_hlp_contractmst_v20
integer x = 1979
integer y = 44
end type

type gb_cond from w_a_hlp`gb_cond within b1w_hlp_contractmst_v20
integer width = 1248
integer height = 352
end type

type dw_hlp from w_a_hlp`dw_hlp within b1w_hlp_contractmst_v20
integer x = 27
integer y = 372
integer width = 4347
integer height = 1188
string dataobject = "b1dw_hlp_contractmst_v20"
boolean livescroll = false
end type

event dw_hlp::ue_init();call super::ue_init;dwObject ldwo_SORT
ldwo_SORT = Object.contractseq_t
uf_init(ldwo_SORT)
end event

