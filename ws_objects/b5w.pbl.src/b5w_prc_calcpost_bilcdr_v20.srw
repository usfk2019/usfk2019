$PBExportHeader$b5w_prc_calcpost_bilcdr_v20.srw
$PBExportComments$[ohj] 요금재계산 Calcpost_bilcdr v20
forward
global type b5w_prc_calcpost_bilcdr_v20 from w_a_prc
end type
end forward

global type b5w_prc_calcpost_bilcdr_v20 from w_a_prc
integer width = 2016
integer height = 1224
end type
global b5w_prc_calcpost_bilcdr_v20 b5w_prc_calcpost_bilcdr_v20

type variables

end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
String ls_customernm, ls_payid

Select customernm,
	 //  status,
	   payid
Into :ls_customernm,
//	 :is_cus_status,
	 :ls_payid
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_input.SetFocus()
   dw_input.SetColumn("customerid")
   Return -1
End If

//Select hotbillflag
//  Into :is_hotbillflag
//  From customerm
// Where customerid = :ls_payid;
//
//If SQLCA.SQLCode = 100 Then		//Not Found
//   f_msg_usr_err(201, Title, "고객번호(납입자번호)")
//   dw_cond.SetFocus()
//   dw_cond.SetColumn("customerid")
//   Return -1
//End If
//
//If IsNull(is_hotbillflag) Then is_hotbillflag = ""
//If is_hotbillflag = 'S' Then    //현재 Hotbilling고객이면 개통신청 못하게 한다.
//   f_msg_usr_err(201, Title, "즉시불처리중인고객")
//   dw_cond.SetFocus()
//   dw_cond.SetColumn("customerid")
//   Return -1
//End If

dw_input.object.customernm[1] = ls_customernm

Return 0

end function

on b5w_prc_calcpost_bilcdr_v20.create
call super::create
end on

on b5w_prc_calcpost_bilcdr_v20.destroy
call super::destroy
end on

event type integer ue_process();
String ls_errmsg,ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_validkey, ls_customerid
Long ll_return
double lb_count


ll_return = -1
ls_errmsg = space(500)
//ls_pgm_id = iu_cust_msg.is_pgm_id
//ls_chargedt = trim(dw_input.Object.chargedt[1])
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")
ls_validkey = dw_input.Object.validkey[1]
ls_customerid= dw_input.Object.customerid[1]

If ls_validkey = '' Then
	setnull(ls_validkey)
End If	


//처리부분...
SQLCA.b5CalcPost_bilcdr_v2(ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_validkey, ls_customerid, 1000, 100, ll_return, ls_errmsg, lb_count)
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
	is_msg_process = String(lb_count, "#,##0") + " Hit(s)"
	Return 0
End If


end event

event type integer ue_input();call super::ue_input;String ls_yyyymmdd_fr, ls_yyyymmdd_to,ls_sysdate
ls_sysdate = string(date(fdt_get_dbserver_now())) 
ls_yyyymmdd_fr = String(dw_input.Object.yyyymmdd_fr[1], "yyyymmdd")
ls_yyyymmdd_to = String(dw_input.Object.yyyymmdd_to[1], "yyyymmdd")

If ls_yyyymmdd_fr = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_fr")
	Return -1
End If


If ls_yyyymmdd_to = "" Then
	f_msg_usr_err(200, This.Title, "")
	dw_input.SetFocus()
	dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If

If ls_yyyymmdd_fr > ls_yyyymmdd_to or ls_yyyymmdd_to >= ls_sysdate Then
	f_msg_info(100, This.Title, "")
	dw_input.SetFocus()
   dw_input.SetColumn("yyyymmdd_to")
	Return -1
End If


Return 0


end event

event open;call super::open;//String ls_module, ls_ref_no, ls_ref_desc
//String ls_yyyymmdd
//
//ls_module = "B5"
//ls_ref_no = "A101" 
//ls_ref_desc = ""
//ls_yyyymmdd = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
//
//If IsNull(ls_yyyymmdd) Then Return
//If ls_yyyymmdd <> "" Then
//    dw_input.Object.yyyymmdd_fr[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	 dw_input.Object.yyyymmdd_to[1] = fd_date_next(date(mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)),1)
//	
//End If;
//
//p_ok.SetFocus()
//
// 
end event

type p_ok from w_a_prc`p_ok within b5w_prc_calcpost_bilcdr_v20
integer x = 1696
integer y = 40
end type

type dw_input from w_a_prc`dw_input within b5w_prc_calcpost_bilcdr_v20
integer x = 64
integer y = 52
integer width = 1509
integer height = 268
string dataobject = "b5d_cnd_prc_calcpost_bilcdr_v20"
boolean hscrollbar = false
boolean vscrollbar = false
end type

event dw_input::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

event dw_input::doubleclicked;call super::doubleclicked;DataWindowChild ldc_svccod
Integer li_exist
Boolean lb_check
String ls_filter

Choose Case dwo.name
	Case "customerid"
		If dw_input.iu_cust_help.ib_data[1] Then
			dw_input.Object.customerid[row] = dw_input.iu_cust_help.is_data[1]
			dw_input.object.customernm[row] = dw_input.iu_cust_help.is_data[2]
//			is_cus_status = dw_input.iu_cust_help.is_data[3]
		End If
End Choose

Return 0 
end event

event dw_input::itemchanged;call super::itemchanged;This.AcceptText()

Choose Case dwo.name
	Case "customerid" 
   	    wfi_get_customerid(data)
End Choose
end event

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_calcpost_bilcdr_v20
integer y = 836
integer width = 1925
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_calcpost_bilcdr_v20
integer y = 372
integer width = 1925
end type

type ln_up from w_a_prc`ln_up within b5w_prc_calcpost_bilcdr_v20
integer beginy = 356
integer endx = 1906
integer endy = 356
end type

type ln_down from w_a_prc`ln_down within b5w_prc_calcpost_bilcdr_v20
integer beginy = 1116
integer endx = 1906
integer endy = 1116
end type

type p_close from w_a_prc`p_close within b5w_prc_calcpost_bilcdr_v20
integer x = 1696
integer y = 148
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_calcpost_bilcdr_v20
integer width = 1550
integer height = 336
end type

