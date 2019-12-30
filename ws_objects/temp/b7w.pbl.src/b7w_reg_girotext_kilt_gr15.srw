$PBExportHeader$b7w_reg_girotext_kilt_gr15.srw
$PBExportComments$[islim] 지로수납파일처리 KILT - GR15 modify
forward
global type b7w_reg_girotext_kilt_gr15 from w_a_reg_m_sql
end type
type p_1 from u_p_fileread within b7w_reg_girotext_kilt_gr15
end type
type p_payment from u_p_payment within b7w_reg_girotext_kilt_gr15
end type
end forward

global type b7w_reg_girotext_kilt_gr15 from w_a_reg_m_sql
integer width = 3209
integer height = 1988
event ue_fileread ( )
event type long ue_open ( )
event ue_payment ( )
p_1 p_1
p_payment p_payment
end type
global b7w_reg_girotext_kilt_gr15 b7w_reg_girotext_kilt_gr15

type variables
String is_paytype
String is_file_name
String is_workdt
Date id_workdt
end variables

event ue_fileread();// EA22 File Search
Constant Integer li_MAX_DIR = 255, li_MAX_FILES = 4097
Boolean	lb_return
Integer	li_return, li_filenum
Integer	li_read_bytes
String	ls_buffer
String	ls_curdir
String	ls_title, ls_pathname, ls_file_name, ls_extension, ls_filter
Long		ll_rows, ll_return
String 	ls_mmdd
String 	ls_temp, ls_ref_desc
String 	ls_workdt_mmdd, ls_prc_filename
String	ls_file_prefix
String 	ls_workdt
Date 		ld_workdt
String	ls_count
String	ls_desc


ls_file_name = Trim(dw_cond.object.file_name[1])
ld_workdt = dw_cond.object.workdt[1]
ls_workdt_mmdd = string(dw_cond.object.workdt[1],'mmdd')

u_api lu_api
lu_api = Create u_api

ls_curdir = Space(li_MAX_DIR)
lu_api.GetCurrentDirectoryA(li_MAX_DIR, ls_curdir)
ls_curdir = Trim(ls_curdir)

ls_title = "Select File"
ls_file_prefix = fs_get_control("B7","B130",ls_desc)  //수납파일명 : GR
ls_pathname = ""
ls_file_name = ""
ls_extension = ""
ls_filter = ls_file_prefix + " Files (" + ls_file_prefix +"*.*), " + ls_file_prefix + "*.*, All Files (*.*),*.*"
li_return = GetFileOpenName(ls_title, ls_pathname, ls_file_name, ls_extension, ls_filter)

If li_return <> 1 Then
	If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
	Destroy lu_api
	f_msg_usr_err(9000, Title, "File 정보가 없습니다.")
	Return
End If

SetPointer(HourGlass!)

//ls_prc_filename = ls_file_prefix + ls_workdt_mmdd
//
//If ls_file_name <> ls_prc_filename Then
//	f_msg_usr_err(9000, Title,"'"+ ls_prc_filename + "' File을 선택하셔야 합니다.")
//	return 
//End if


If LenA(ls_curdir) > 0 Then lb_return = lu_api.SetCurrentDirectoryA(ls_curdir)
Destroy lu_api


ls_pathname = Upper(ls_pathname)
ls_file_name = Upper(ls_file_name)

b7u_dbmgr4 lu_dbmgr
lu_dbmgr = Create b7u_dbmgr4

lu_dbmgr.is_caller = "b7w_reg_girotext_kilt_gr15%ue_fileread"  //2005.04.14 juede gr15 modify
lu_dbmgr.is_Title = This.Title
lu_dbmgr.is_data[1] = ls_pathname	// 파일명
lu_dbmgr.is_data[2] = ls_file_name
lu_dbmgr.is_data[3] = gs_user_id
lu_dbmgr.is_data[4] = gs_pgm_id[gi_open_win_no]

lu_dbmgr.uf_prc_db_02()  //2005.04.14 juede gr15 modify

If lu_dbmgr.ii_rc < 0 THen
	//ROLLBACK;
	commit;
	Destroy lu_dbmgr
	f_msg_usr_err(9000, This.Title, "파일이 비정상이거나, 이미 처리된 파일입니다.")
	//모래시계 표시해제
	SetPointer(Arrow!)
	return
Elseif lu_dbmgr.ii_rc = 0 then
	COMMIT;
	ls_count = lu_dbmgr.is_data2[1]
	ls_workdt = lu_dbmgr.is_data2[2]
	is_file_name = ls_file_name
	is_workdt = ls_workdt
	//id_workdt = ld_workdt
	f_msg_info(3000, Title, "지로수납 파일입력(건수 : " + ls_count+ ")")
	
//	This.TriggerEvent("ue_payment")
End IF

//모래시계 표시해제
SetPointer(Arrow!)

TriggerEvent('ue_open')
//TriggerEvent('ue_ok')

Destroy lu_dbmgr
end event

event type long ue_open();String ls_temp, ls_ref_desc, ls_status[]
Integer li_return
String ls_file_name
Date ld_workdt


p_payment.TriggerEvent('ue_disable')


ls_temp = fs_get_control("B7", "B100", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_status[])


SELECT file_name, workdt
INTO :ls_file_name, :ld_workdt
FROM girotextstatus
WHERE status = :ls_status[1]; // status = 수납파일

If ls_file_name <> "" Then
	dw_cond.object.file_name[1] = ls_file_name
	dw_cond.object.workdt[1] = ld_workdt
	//dw_cond.object.msg_1.visible = True
	//dw_cond.object.msg_2.visible = False
	This.TriggerEvent("ue_ok")
Else
	
	//dw_cond.object.msg_2.visible = True
	//dw_cond.object.msg_1.visible = False
End If

Return 0
end event

event ue_payment();//입력한 내역을 입금 반영 처리
String ls_errmsg, ls_pgm_id, ls_check_yn
String ls_temp, ls_ref_desc
String ls_pay_type[], ls_this_paytype
String ls_status[], ls_this_status
String ls_trcod[], ls_this_trcod
String ls_file_name
String ls_workdt
Date ld_workdt
Double lb_count
Long  ll_return
Int    li_cnt

ls_errmsg = space(256)
ls_pgm_id = gs_pgm_id[gi_open_win_no]
ll_return = -1

//입금유형(REQDTL:PAYTYPE)
ls_temp = fs_get_control("B5", "I101", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_pay_type[])
//입금유형- 지로입금type
ls_this_paytype = ls_pay_type[2]
If IsNull(ls_this_paytype) Or ls_this_paytype = "" Then Return 

//입금거래유형(REQDTL:TRCOD)
ls_temp = fs_get_control("B5", "I102", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , ls_trcod[])
//거래유형- 지로입금type
ls_this_trcod = ls_trcod[2]
If IsNull(ls_this_trcod) Or ls_this_trcod = "" Then Return 



////해당 row의 자료가 없을때..
If dw_detail.RowCount() = 0  Then Return

SetPointer(HourGlass!)

//SELECT BANKTEXT -> INSERT REQPAY 표준입금반영
SQLCA.B7GIROREQPAY(ls_this_paytype,ls_this_trcod,gs_user_id,ls_pgm_id,ll_return,ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	SetPointer(Arrow!)
	Return 
ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

//ReqPay --> PayDtl
SQLCA.B5REQPAY2DTL_NOSEQ(ls_this_paytype, gs_user_id, ls_pgm_id,ll_return, ls_errmsg,lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText,StopSign!)
	SetPointer(Arrow!)
	Return 

ElseIf ll_return < 0 Then	//For User
	MessageBox(Title, ls_errmsg, StopSign!)
End If

If ll_return <> 0 Then	//실패
	f_msg_info(3000, Title, "입금TR생성이 되지 않았습니다.")
	SetPointer(Arrow!)
	Return 
Else							//성공
	//f_msg_info(3000, Title, "지로수납 입금 처리 반영(건수 : " + String(lb_count)+ ")")
	f_msg_info(3000, Title, "지로수납 입금 처리 반영")
	//GIROTEXTSTATUS.STATUS UPDATE
	//B7:B100 -지로결제작업상태(수납파일;표준입금;TR입금)
	ls_temp = fs_get_control("B7", "B100", ls_ref_desc)
	If ls_temp = "" Then
		f_msg_info(3000, Title, "지로결재작업로그(GIROTEXTSTATUS) Update Error")
		SetPointer(Arrow!)
		Return
	END IF
	fi_cut_string(ls_temp, ";" , ls_status[])
	//작업상태- (3)TR입금
	ls_this_status = ls_status[3]
	If IsNull(ls_this_trcod) Or ls_this_trcod = "" Then 
		f_msg_info(3000, Title, "지로결재작업로그(GIROTEXTSTATUS) Update Error")
		SetPointer(Arrow!)
		Return 
	END IF
	
	ls_file_name = is_file_name
	ls_workdt = is_workdt
	
	UPDATE girotextstatus
	SET status = :ls_this_status
	WHERE file_name = :ls_file_name
		AND workdt = :ls_workdt;
	
	IF SQLCA.SQLCODE < 0 THEN
		f_msg_info(3000, Title, "지로결재작업로그(GIROTEXTSTATUS) Update Error")
		ROLLBACK;
		SetPointer(Arrow!)
		RETURN
	END IF
	
	COMMIT;

End If

SetPointer(Arrow!)

p_payment.TriggerEvent('ue_disable')
This.TriggerEvent('ue_ok')

Return

end event

on b7w_reg_girotext_kilt_gr15.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_payment=create p_payment
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_payment
end on

on b7w_reg_girotext_kilt_gr15.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_payment)
end on

event open;call super::open;TriggerEvent('ue_open')
end event

event ue_ok();call super::ue_ok;
String ls_file_name
String ls_payid
String ls_workdt
String ls_inqnum
String ls_taketype
String ls_giro_type
String ls_bil_status
String ls_transdt_from
String ls_transdt_to
String ls_where
Long ll_rows

String ls_temp, ls_ref_desc, ls_status[]
String ls_work_status
Int li_return, li_count

ls_file_name = Trim(dw_cond.object.file_name[1])
ls_payid = Trim(dw_cond.object.payid[1])
ls_workdt = String(dw_cond.object.workdt[1],"YYYYMMDD")
ls_inqnum = Trim(dw_cond.object.inqnum[1])
ls_taketype = Trim(dw_cond.object.taketype[1])
ls_giro_type = Trim(dw_cond.object.giro_type[1])
ls_bil_status = Trim(dw_cond.object.bil_status[1])
ls_transdt_from = String(dw_cond.object.transdt_from[1],"YYYYMMDD")
ls_transdt_to = String(dw_cond.object.transdt_to[1],"YYYYMMDD")

If IsNull(ls_file_name) Then ls_file_name = ""
If IsNull(ls_payid) Then ls_payid = ""
If IsNull(ls_workdt) Then ls_workdt = ""
If IsNull(ls_inqnum) Then ls_inqnum = ""
If IsNull(ls_taketype) Then ls_taketype = ""
If IsNull(ls_giro_type) Then ls_giro_type = ""
If IsNull(ls_bil_status) Then ls_bil_status = ""
If IsNull(ls_transdt_from) Then ls_transdt_from = ""
If IsNull(ls_transdt_to) Then ls_transdt_to = ""


// Dynamic SQL
ls_where = ""

If ls_file_name <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "file_name = '" + ls_file_name + "' "
End If

If ls_payid <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "payid = '" + ls_payid + "' "
End If

If ls_workdt <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(workdt, 'yyyymmdd') = '" + ls_workdt + "' "
End If

If ls_inqnum <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "inqnum = '" + ls_inqnum + "' "
End If

If ls_taketype <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "taketype = '" + ls_taketype + "' "
End If

If ls_giro_type <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "giro_type = '" + ls_giro_type + "' "
End If

If ls_bil_status <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "bil_status = '" + ls_bil_status + "' "
End If

If ls_transdt_from <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(transdt, 'yyyymmdd') >= '" + ls_transdt_from + "' "
End If

If ls_transdt_to <> "" Then
	If ls_where <> "" Then ls_where += " AND "
	ls_where += "to_char(transdt, 'yyyymmdd') <= '" + ls_transdt_to + "' "
End If

dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()

If ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_rows = 0 Then
	f_msg_usr_err(1100, Title, "Detail")
	Return
End If

//지로결재작업로그 확인 = 상태가 '수납파일처리'((B7:B100)의 첫번째 값)일 때 Payment 버튼 활성
ls_temp = fs_get_control("B7", "B100", ls_ref_desc)
li_return = fi_cut_string(ls_temp, ";", ls_status[])

SELECT count(*)
INTO :li_count
FROM girotextstatus
WHERE status = :ls_status[1];

If li_count > 0 Then

	p_1.TriggerEvent('ue_disable')
	
	SELECT status
	INTO : ls_work_status
	FROM girotextstatus
	WHERE file_name = :ls_file_name
	AND workdt = :ls_workdt;
	
	
	IF ls_work_status = ls_status[1] THEN
		p_payment.TriggerEvent('ue_enable')
		
	ELSE 
		p_payment.TriggerEvent('ue_disable')
		
	END IF
	
ELSE 
	p_payment.TriggerEvent('ue_disable')
	p_1.TriggerEvent('ue_enable')
END IF		
	
end event

type dw_cond from w_a_reg_m_sql`dw_cond within b7w_reg_girotext_kilt_gr15
integer width = 2094
integer height = 496
string dataobject = "b7dw_cnd_reg_girotext"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::ue_init();call super::ue_init;This.idwo_help_col[1] = This.Object.payid
This.is_help_win[1] = "b1w_hlp_payid"
This.is_data[1] = "CloseWithReturn"
end event

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.Name
	Case "payid"
		If iu_cust_help.ib_data[1] Then
			Object.payid[row] = iu_cust_help.is_data[1]
		End If
End Choose
end event

event dw_cond::itemchanged;call super::itemchanged;Choose Case dwo.Name
	Case "file_name"
		Date ld_workdt
		String ls_status

		SELECT workdt, status
		INTO :ld_workdt, :ls_status
		FROM girotextstatus
		WHERE file_name = :data; // status = 수납파일
		
		If ls_status <> "" Then
			dw_cond.object.workdt[1] = ld_workdt
			//dw_cond.object.bil_status[1] = ls_status
		End If		
		
		
End Choose

Return 0
end event

type p_ok from w_a_reg_m_sql`p_ok within b7w_reg_girotext_kilt_gr15
integer x = 2309
integer y = 116
boolean originalsize = false
end type

type p_close from w_a_reg_m_sql`p_close within b7w_reg_girotext_kilt_gr15
integer x = 2619
integer y = 116
end type

type gb_cond from w_a_reg_m_sql`gb_cond within b7w_reg_girotext_kilt_gr15
integer width = 2149
integer height = 552
end type

type p_save from w_a_reg_m_sql`p_save within b7w_reg_girotext_kilt_gr15
boolean visible = false
end type

type dw_detail from w_a_reg_m_sql`dw_detail within b7w_reg_girotext_kilt_gr15
integer x = 37
integer y = 576
integer width = 3099
integer height = 1284
string dataobject = "b7dw_reg_girotext_mst_kilt"
end type

event dw_detail::ue_init();call super::ue_init;dwObject ldwo_sort

ib_sort_use = True
ib_highlight = True

ldwo_sort = Object.bil_status_t
uf_init(ldwo_sort,"D",RGB(0,0,128))

end event

type p_1 from u_p_fileread within b7w_reg_girotext_kilt_gr15
integer x = 2309
integer y = 244
boolean bringtotop = true
boolean originalsize = false
end type

type p_payment from u_p_payment within b7w_reg_girotext_kilt_gr15
integer x = 2619
integer y = 244
boolean bringtotop = true
boolean originalsize = false
end type

event clicked;call super::clicked;//////
end event

