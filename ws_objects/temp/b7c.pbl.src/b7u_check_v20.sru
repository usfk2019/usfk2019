$PBExportHeader$b7u_check_v20.sru
$PBExportComments$[jsha]
forward
global type b7u_check_v20 from u_cust_a_db
end type
end forward

global type b7u_check_v20 from u_cust_a_db
end type
global b7u_check_v20 b7u_check_v20

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_sysdate, ls_resultdt, ls_temp, ls_result[], ls_ref_desc, ls_status, ls_day
Int li_return, li_cnt

ii_rc = -2
Choose Case is_caller
	Case "b7w_req_card_invfile_v20%ue_ok"
		// 승인완료상태 : B7, C100의 세번째 Value
		ls_temp = fs_get_control("B7", "C100", ls_ref_desc)
		li_return = fi_cut_string(ls_temp, ";", ls_result[])
		ls_status = ls_result[3]
		
		SELECT to_char(sysdate, 'yyyy-mm-dd')
		INTO	:ls_sysdate
		FROM	dual;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "sysdate select error")
		End If
		
		// System Date Check
		If is_data[1] >= ls_sysdate Then
			f_msg_usr_err(9000, is_title, "승인/매출일자는 오늘날짜보다 작아야 합니다.")
			Return
		End If
		
		// Holiday Check
		SELECT to_char(to_date(:is_data[1],'yyyy-mm-dd'), 'd')
		INTO	:ls_day
		FROM	dual;
		
		If ls_day = '1' Or ls_day = '7' Then
			f_msg_usr_err(9000, is_title, "승인/매출일자는 토, 일요일 및 공휴일이 아니어야 합니다.")
			Return
		End If
		
		SELECT count(hday)
		INTO	:li_cnt
		FROM	holiday
		WHERE	to_char(hday, 'yyyy-mm-dd') = to_char(:id_data[1], 'yyyy-mm-dd');
		
		If li_cnt > 0 Then
			f_msg_usr_err(9000, is_title, "승인/매출일자는 토, 일요일 및 공휴일이 아니어야 합니다.")
			Return
		End If
		
		// Cardreqstatus의 resultprcdt보다 승인일자가 크거나 같아야 한다.
		SELECT MAX(to_char(resultprcdt, 'yyyy-mm-dd'))
		INTO	:ls_resultdt
		FROM	cardreqstatus
		WHERE	status  = :ls_status
		AND	reqprcdt <= to_date(:is_data[1], 'yyyy-mm-dd')+0.99999;
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_Title, "SELECT RESULTPRCDT FROM CARDREQSTATUS")
		End If
		
		If is_data[1] < ls_resultdt Then
			f_msg_usr_err(9000, is_title, "승인/매출일자는 가장 최근의 승인일자보다 커야 합니다.")
			Return
		End If
End Choose

ii_rc = 0
Return
		
end subroutine

on b7u_check_v20.create
call super::create
end on

on b7u_check_v20.destroy
call super::destroy
end on

