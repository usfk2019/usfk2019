$PBExportHeader$b5w_prc_taxsheetinfo.srw
$PBExportComments$[jwlee] 세금계산서발행( 선납품목용)
forward
global type b5w_prc_taxsheetinfo from w_a_prc
end type
end forward

global type b5w_prc_taxsheetinfo from w_a_prc
end type
global b5w_prc_taxsheetinfo b5w_prc_taxsheetinfo

type variables
String is_type[]
end variables

on b5w_prc_taxsheetinfo.create
call super::create
end on

on b5w_prc_taxsheetinfo.destroy
call super::destroy
end on

event ue_process;call super::ue_process;String ls_errmsg, ls_taxissuedt, ls_paydt, ls_type, ls_pgm_id
Double ldb_count
Long   ldb_return
dw_input.Accepttext()

ldb_return = -1
ls_errmsg = space(256)
ls_pgm_id = iu_cust_msg.is_pgm_id
ls_taxissuedt = string(dw_input.Object.taxissuedt[1],'YYYYMMDD')
ls_paydt      = string(dw_input.Object.paydt[1],'YYYYMMDD')
ls_type       = dw_input.Object.type[1]

//처리부분...
SQLCA.B5W_PRE_TAXSHEETINFO(ls_taxissuedt,ls_paydt,ls_type,gs_user_id,ls_pgm_id,ldb_return, ls_errmsg, ldb_count)

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

event ue_input;call super::ue_input;String ls_taxissuedt, ls_sysdate, ls_paydt, ls_date

ls_sysdate    = string(date(fdt_get_dbserver_now())) 
ls_taxissuedt = String(dw_input.Object.taxissuedt[1], "yyyymmdd")
ls_paydt      = String(dw_input.Object.paydt[1], "yyyymmdd")
ls_date       = String(fd_date_pre(date(fdt_get_dbserver_now()),1),'yyyymmdd')

//발행일자이 현재일보다 큰지 체크
IF  (ls_taxissuedt > ls_sysdate) THEN
	f_msg_usr_err(212, Title + "today:" + ls_taxissuedt, "발행일자")
	dw_input.SetColumn("taxissuedt")
	dw_input.SetFocus()
	RETURN -1
END IF

//수납일은 어제일보다 클수는 없다.
IF  (ls_paydt > ls_date) THEN
	f_msg_usr_err(212, Title + "today:" + ls_paydt, "수납일자")
	dw_input.SetColumn("paydt")
	dw_input.SetFocus()
	RETURN -1
END IF

If ls_taxissuedt = "" Then
	f_msg_usr_err(200, This.Title, "발행일자")
	dw_input.SetFocus()
	dw_input.SetColumn("taxissuedt")
	Return -1
End If

Return 0


end event

event open;call super::open;String ls_date, ls_temp, ls_ref_desc

//세금계산서 발행
ls_temp = fs_get_control("B5", "T210", ls_ref_desc) 

If ls_temp = "" Then Return 0
fi_cut_string(ls_temp, ";" , is_type[])

If is_type[2] = "" Then
	f_msg_usr_err(9000, Title, "세금계산서 발행Type 정보가 없습니다.(SYSCTL1T:B5:T210)")
	Close(This)
End If

dw_input.SetFocus()
dw_input.Object.taxissuedt[1] = date(fdt_get_dbserver_now())
dw_input.Object.paydt[1]      = fd_date_pre(date(fdt_get_dbserver_now()),1)
dw_input.Object.type[1]       = is_type[2]

 
end event

type p_ok from w_a_prc`p_ok within b5w_prc_taxsheetinfo
end type

type dw_input from w_a_prc`dw_input within b5w_prc_taxsheetinfo
integer width = 1138
string dataobject = "b5dw_cnd_prc_taxsheetinfo"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type dw_msg_time from w_a_prc`dw_msg_time within b5w_prc_taxsheetinfo
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within b5w_prc_taxsheetinfo
end type

type ln_up from w_a_prc`ln_up within b5w_prc_taxsheetinfo
end type

type ln_down from w_a_prc`ln_down within b5w_prc_taxsheetinfo
end type

type p_close from w_a_prc`p_close within b5w_prc_taxsheetinfo
end type

type gb_cond from w_a_prc`gb_cond within b5w_prc_taxsheetinfo
integer width = 1179
end type

