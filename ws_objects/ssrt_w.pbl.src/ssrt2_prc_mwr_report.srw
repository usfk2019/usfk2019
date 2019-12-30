$PBExportHeader$ssrt2_prc_mwr_report.srw
$PBExportComments$[hcjung] MWR 리포트 리스트 생성
forward
global type ssrt2_prc_mwr_report from w_a_prc
end type
end forward

global type ssrt2_prc_mwr_report from w_a_prc
integer height = 1224
end type
global ssrt2_prc_mwr_report ssrt2_prc_mwr_report

event open;call super::open;Integer li_return
String ls_ref_content, ls_ref_desc, ls_temp, ls_return[], ls_test, is_last_date
Date ld_bildt, ld_bildt_ctl

iu_cust_msg = create u_cust_a_msg 

ls_ref_desc = ""
is_last_date = fs_get_control("S9", "S100", ls_ref_desc) + '01'

dw_input.Object.todate[1] = fd_month_next(date(string(is_last_date, '@@@@-@@-@@')),1)
end event

on ssrt2_prc_mwr_report.create
call super::create
end on

on ssrt2_prc_mwr_report.destroy
call super::destroy
end on

event ue_input;String ls_todate

ls_todate = String(dw_input.Object.todate[1],'yyyymm')

If IsNull(ls_todate) Then ls_todate = ""

If ls_todate = "" Then
	f_msg_info(9000, Title, "생성 월을 입력하십시오.")
	dw_input.SetFocus()
	dw_input.SetColumn('todate')
	Return -1
End If

Return 0

end event

event ue_process;//프로시저 Call
String ls_todate,ls_pgm_id
String ls_errmsg
double lb_return
double lb_count

lb_return = -1
ls_errmsg = space(256)

ls_todate = String(dw_input.Object.todate[1],'yyyymm')

//처리부분...
SQLCA.S1W_PRC_MWR_REPORT(ls_todate, gs_user_id, gs_pgm_id[1], lb_return, ls_errmsg, lb_count)

If SQLCA.SQLCode < 0 Then		//For Programer
	MessageBox(This.Title+'~r~n'+ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
	lb_return = -1

ElseIf lb_return < 0 Then	//For User
	MessageBox(This.Title, ls_errmsg)
	
End If

If lb_return <> 0 Then	Return -1

If IsNull(lb_count) Then lb_count = 0

/* 2014.02.07 [#6947]일감 요청으로 로직추가함 by 김선주 */
SELECT Nvl(count(*),0) 
  INTO :lb_count
  FROM MWR_REPORT_LIST
 WHERE YYYYMM = Trim(:ls_todate);
	
is_msg_process = String(lb_count, "#,##0") + "건"

Return 0



end event

event ue_ok;/*2014.04.18 김선주  */
/*데이타 존재 여부에 따라, bloking로직을 넣어달라는 요청에 따라 */
/*Extend Ancestor Script를 막고, */
/*아래와 같이 기술함(수정전에는 해당 ue_ok에 로직이 없었음*/


Integer li_rc
String ls_todate, ls_exist_yn

//***** 초기화 작업 *****
SetPointer(HourGlass!)

//***** 입력 부분 *****
If dw_input.AcceptText() < 0 Then
	dw_input.SetFocus()
	Return
End If

ls_todate = String(dw_input.Object.todate[1],'yyyymm')

If This.Trigger Event ue_input() < 0 Then
//	//Input Mode로
	Trigger Event ue_chg_mode("INPUT")
	Return
End If

/* 2014.02.07 [#6947]일감 요청으로 로직추가함 by 김선주 */
Select Decode(count(*),0,'N',NULL,'N','Y')
  Into :ls_exist_yn
  From MWR_REPORT
 Where yyyymm = Trim(:ls_todate) ;
 
If ls_exist_yn = 'Y' Then 
	Messagebox("Information", "MWR Data is already existed, Change the input month!");
	Return 
End if;	


if ls_exist_yn = 'N' Then 
//실행의 확인 작업
il_msg_no = 200
li_rc = f_msg_ques_yesno2(il_msg_no, Title, is_msg_text, 1)

	If li_rc <> 1 Then
//	//Input Mode로
		Trigger Event ue_chg_mode("INPUT")  
		Return
	End If
END IF 


//***** Process부분 *****
//Process Mode로
Trigger Event ue_chg_mode("PROCESS")

//Process call
li_rc = Trigger Event ue_process()

If Trigger Event ue_pre_complete() < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()

	//Input Mode로
	Trigger Event ue_chg_mode("INPUT")
	f_msg_info(3010, Title, iu_cust_msg.is_pgm_name)
Else
	//Completed Mode로
	Trigger Event ue_chg_mode("COMPLETED")
End If

If li_rc < 0 Then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()
	f_msg_info(3010, Title, iu_cust_msg.is_pgm_name)
Else
	//COMMIT;와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = Title

	iu_cust_db_app.uf_prc_db()

	f_msg_info(3000, Title, iu_cust_msg.is_pgm_name)
End If

end event

type p_ok from w_a_prc`p_ok within ssrt2_prc_mwr_report
integer y = 36
end type

type dw_input from w_a_prc`dw_input within ssrt2_prc_mwr_report
integer y = 48
integer width = 1079
integer height = 176
string dataobject = "ssrt2_cnd_prc_mwr_report"
end type

type dw_msg_time from w_a_prc`dw_msg_time within ssrt2_prc_mwr_report
integer y = 812
end type

type dw_msg_processing from w_a_prc`dw_msg_processing within ssrt2_prc_mwr_report
integer y = 348
end type

type ln_up from w_a_prc`ln_up within ssrt2_prc_mwr_report
integer beginy = 324
integer endy = 324
end type

type ln_down from w_a_prc`ln_down within ssrt2_prc_mwr_report
integer beginy = 1100
integer endy = 1100
end type

type p_close from w_a_prc`p_close within ssrt2_prc_mwr_report
integer y = 144
end type

type gb_cond from w_a_prc`gb_cond within ssrt2_prc_mwr_report
integer width = 1152
integer height = 256
end type

