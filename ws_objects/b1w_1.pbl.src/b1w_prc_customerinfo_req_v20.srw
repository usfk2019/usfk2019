$PBExportHeader$b1w_prc_customerinfo_req_v20.srw
$PBExportComments$[jwlee] 고객정보요청자료 생성
forward
global type b1w_prc_customerinfo_req_v20 from w_a_prc
end type
end forward

global type b1w_prc_customerinfo_req_v20 from w_a_prc
end type
global b1w_prc_customerinfo_req_v20 b1w_prc_customerinfo_req_v20

on b1w_prc_customerinfo_req_v20.create
call super::create
end on

on b1w_prc_customerinfo_req_v20.destroy
call super::destroy
end on

event ue_process;call super::ue_process;String ls_errmsg,ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_partner,ls_pgm_id
Double ldb_count
Long   ldb_return
dw_input.Accepttext()

ldb_return = -1
ls_errmsg = space(256)
ls_yyyymmdd_fr = fs_snvl(string(dw_input.Object.fromdt[1],'YYYYMMDD'),'19000101')
ls_yyyymmdd_to = string(dw_input.Object.todt[1],'YYYYMMDD')
ls_partner     = dw_input.Object.partner[1]

//처리부분...
SQLCA.B1CUSTOMERINFO_REQ(ls_yyyymmdd_fr,ls_yyyymmdd_to,ls_partner,gs_user_id, ldb_return, ls_errmsg, ldb_count)
If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	ldb_return = -1
ElseIf ldb_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
End If


If ldb_return <> 0 Then	//실패
	is_msg_process = "Fail"
	Return -1
Else				//성공
	is_msg_process = "Count: " + String(ldb_count, "#,##0") + " 건"
	Return 0
End If


end event

event ue_input;call super::ue_input;String ls_todt, ls_sysdate, ls_frdt

ls_sysdate = string(date(fdt_get_dbserver_now())) 
ls_todt = String(dw_input.Object.todt[1], "yyyymmdd")
ls_frdt = String(dw_input.Object.fromdt[1], "yyyymmdd")

//작업일자 to < 작업일자 from
IF  (ls_frdt > ls_todt) THEN
	f_msg_usr_err(212, Title + "today:" + ls_frdt, "작업일자")
	dw_input.SetColumn("fromdt")
	dw_input.SetFocus()
	RETURN -1
END IF

If ls_todt = "" Then
	f_msg_usr_err(200, This.Title, "작업일자")
	dw_input.SetFocus()
	dw_input.SetColumn("todt")
	Return -1
End If

Return 0


end event

event open;call super::open;String ls_date
//String ls_module, ls_ref_no, ls_ref_desc
//String ls_yyyymmdd
//ls_yyyymmdd = string(today(),'YYYYMMDD')
//dw_input.Object.idate_fr[1] = mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)
//dw_input.Object.idate_to[1] = mid(ls_yyyymmdd,1,4) + '-' + mid(ls_yyyymmdd,5,2) + '-' + mid(ls_yyyymmdd,7,2)

//작업일자
//ls_temp = fs_get_control("Z1", "A300", ls_ref_desc)
//If ls_temp = "" Then Return
//fi_cut_string(ls_temp, ";" , ls_date)
//dw_input.Object.idate_to[1] = mid(ls_date,1,4) + '-' + mid(ls_date,5,2) + '-' + mid(ls_date,7,2)
//

dw_input.SetFocus()

 
end event

type p_ok from w_a_prc`p_ok within b1w_prc_customerinfo_req_v20
end type

type dw_input from w_a_prc`dw_input within b1w_prc_customerinfo_req_v20
string dataobject = "b1dw_cnd_prc_customerinfo_req_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b1w_prc_customerinfo_req_v20
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b1w_prc_customerinfo_req_v20
end type

type ln_up from w_a_prc`ln_up within b1w_prc_customerinfo_req_v20
end type

type ln_down from w_a_prc`ln_down within b1w_prc_customerinfo_req_v20
end type

type p_close from w_a_prc`p_close within b1w_prc_customerinfo_req_v20
end type

type gb_cond from w_a_prc`gb_cond within b1w_prc_customerinfo_req_v20
end type

