$PBExportHeader$b4u_check_v20.sru
$PBExportComments$[ssong]
forward
global type b4u_check_v20 from u_cust_a_check
end type
end forward

global type b4u_check_v20 from u_cust_a_check
end type
global b4u_check_v20 b4u_check_v20

forward prototypes
public subroutine uf_prc_check_2 ()
end prototypes

public subroutine uf_prc_check_2 ();Long ll_seq, ll_row, i
String ls_deposit_type, ls_fromdt, ls_seq, ls_payid, ls_svccod
Dec    ldc_deposit_amt

//2005.09.26 JUEDE =====START
STRING ls_contact  //담당자

ii_rc = -1
Choose Case is_caller


   Case "b4w_reg_deposit_v20%save_tab2"
//		lu_check.is_caller = "b1w_reg_deposit%save_tab2"
//		lu_check.is_title = Title
//		lu_check.ii_data[1] = li_tab
//		lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		For i = 1 To ll_row
			ls_deposit_type = Trim(idw_data[1].object.deposit_type[i])
			ls_fromdt = Trim(String(idw_data[1].Object.fromdt[i],'yyyymmdd'))
			ls_payid = Trim(idw_data[1].object.payid[i])
			ls_svccod = Trim(idw_data[1].object.svccod[i])
			ldc_deposit_amt = idw_data[1].Object.deposit_amt[i]
			
		  If IsNull(ls_deposit_type) Then ls_deposit_type = ""
		  If ls_fromdt = "000000" Then ls_fromdt = ""
		  If IsNull(ldc_deposit_amt) Then ldc_deposit_amt = 0
			
			If ls_deposit_type = "" Then
				f_msg_usr_err(200, is_title, "보증금유형")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("deposit_type")
				ii_rc = -2
				Return 
			End If
				
				If ls_fromdt = "" Then
				f_msg_usr_err(200, is_title, "유효기간from")	
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("fromdt")
				ii_rc = -2
				Return 
			End If
				
			If ldc_deposit_amt = 0 Then 
				f_msg_usr_err(200, is_title, "금액")	
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("deposit_amt")
				ii_rc = -2
				Return 
			End If
				
			
			ls_seq = String(idw_data[1].object.seq[i])
			If IsNull(ls_seq) Then ls_seq = ""
			
//			If ls_seq = "" Then
//				Select Nvl(max(seq),0) + 1
//				Into :ll_seq
//				From customer_deposit_det
//				Where payid  = :ls_payid
//				And   svccod = :ls_svccod;
//				
//				If SQLCA.SQLCode < 0 Then
//					f_msg_sql_err(is_caller, "Sequence Error")
//					RollBack;
//					Return 
//				End If				
//				idw_data[1].object.seq[i] = ll_seq
//			End If
			
	 Next
   
	/*******************************************************
	 *  2005.09.29 JUEDE
	 *  보증금 담당자 정보 등록
	 *******************************************************/
   Case "b4w_reg_deposit_v20%save_tab3"
		//lu_check.is_caller = "b1w_reg_deposit%save_tab3"
		//lu_check.is_title = Title
		//lu_check.ii_data[1] = li_tab
		//lu_check.idw_data[1] = tab_1.idw_tabpage[ai_select_tab]
		
		ll_row = idw_data[1].RowCount()
		If ll_row = 0 Then
			ii_rc = 0 
			Return
		End If
		
		For i = 1 To ll_row
			ls_contact = Trim(idw_data[1].object.contact[i])
			ls_payid = Trim(idw_data[1].object.payid[i])
			ls_svccod = Trim(idw_data[1].object.svccod[i])

			
		  If IsNull(ls_contact) Then ls_contact = ""
	
			If ls_contact = "" Then
				f_msg_usr_err(200, is_title, "담당자")
				idw_data[1].SetFocus()
				idw_data[1].ScrollToRow(i)
				idw_data[1].SetColumn("contact")
				ii_rc = -2
				Return 
			End If				
				
			
			ls_seq = String(idw_data[1].object.seq[i])
			If IsNull(ls_seq) Then ls_seq = ""						
	 Next	 
		
	
End Choose
ii_rc = 0


end subroutine

on b4u_check_v20.create
call super::create
end on

on b4u_check_v20.destroy
call super::destroy
end on

