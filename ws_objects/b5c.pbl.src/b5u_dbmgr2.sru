$PBExportHeader$b5u_dbmgr2.sru
$PBExportComments$[kwon]
forward
global type b5u_dbmgr2 from u_cust_a_db
end type
end forward

global type b5u_dbmgr2 from u_cust_a_db
end type
global b5u_dbmgr2 b5u_dbmgr2

type prototypes

end prototypes

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_billtrcod, ls_type
Int li_billseq
Int li_seq = 0

 
ii_rc = -1 

Choose Case is_caller		

	Case "b5w_prt_reqdtlhot_payid%ue_ok"
		//청구내역항목
		//lu_dbmgr.is_caller   = "b5w_prt_reqdtlhot_payid%ue_ok"
		//lu_dbmgr.is_title    = parent.Title
		//is_data[1] = ls_type  : 사업자고객번호
		//lu_dbmgr.idw_data[1] = dw_list
		
		ls_type = is_data[1]
		
		DECLARE cur_read_billtrcod CURSOR FOR
		SELECT a.codenm , b.billseq
		FROM syscod2t a, trcode b
		WHERE a.code = b.billtrcod and a.grcode = 'B321'
		GROUP BY a.codenm, b.billseq
		ORDER BY b.billseq;
		  

		OPEN cur_read_billtrcod;
		Do While(True)
			FETCH cur_read_billtrcod
			INTO :ls_billtrcod, :li_billseq;

			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_billtrcod")
				CLOSE cur_read_billtrcod;
				Return
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If
			
			Choose Case li_billseq
				Case 1
					idw_data[1].Object.billseq_1_t.text  = ls_billtrcod
				Case 2
					idw_data[1].Object.billseq_2_t.text  = ls_billtrcod
				Case 3
					idw_data[1].Object.billseq_3_t.text  = ls_billtrcod
				Case 4
					idw_data[1].Object.billseq_4_t.text  = ls_billtrcod
				Case 5
					idw_data[1].Object.billseq_5_t.text  = ls_billtrcod
				Case 6
					idw_data[1].Object.billseq_6_t.text  = ls_billtrcod
				Case 7
					idw_data[1].Object.billseq_7_t.text  = ls_billtrcod
				Case 8
					idw_data[1].Object.billseq_8_t.text  = ls_billtrcod
				Case 9
					idw_data[1].Object.billseq_9_t.text  = ls_billtrcod
				Case 10
					idw_data[1].Object.billseq_10_t.text = ls_billtrcod
				Case 11
					idw_data[1].Object.billseq_11_t.text = ls_billtrcod
				Case 12
					idw_data[1].Object.billseq_12_t.text = ls_billtrcod
				Case 13
					idw_data[1].Object.billseq_13_t.text = ls_billtrcod
				Case 14
					idw_data[1].Object.billseq_14_t.text = ls_billtrcod
			End Choose
			
			If ls_type = "detail" Then
				Choose Case li_billseq
					Case 1
						idw_data[1].Object.billseq_1_p.text  = ls_billtrcod
					Case 2
						idw_data[1].Object.billseq_2_p.text  = ls_billtrcod
					Case 3
						idw_data[1].Object.billseq_3_p.text  = ls_billtrcod
					Case 4
						idw_data[1].Object.billseq_4_p.text  = ls_billtrcod
					Case 5
						idw_data[1].Object.billseq_5_p.text  = ls_billtrcod
					Case 6
						idw_data[1].Object.billseq_6_p.text  = ls_billtrcod
					Case 7
						idw_data[1].Object.billseq_7_p.text  = ls_billtrcod
					Case 8
						idw_data[1].Object.billseq_8_p.text  = ls_billtrcod
					Case 9
						idw_data[1].Object.billseq_9_p.text  = ls_billtrcod
					Case 10
						idw_data[1].Object.billseq_10_p.text = ls_billtrcod
					Case 11
						idw_data[1].Object.billseq_11_p.text = ls_billtrcod
					Case 12
						idw_data[1].Object.billseq_12_p.text = ls_billtrcod
					Case 13
						idw_data[1].Object.billseq_13_p.text = ls_billtrcod
					Case 14
						idw_data[1].Object.billseq_14_p.text = ls_billtrcod
				End Choose
			End if
			
		Loop
		CLOSE cur_read_billtrcod;		
						
	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 							"Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0

end subroutine

on b5u_dbmgr2.create
call super::create
end on

on b5u_dbmgr2.destroy
call super::destroy
end on

