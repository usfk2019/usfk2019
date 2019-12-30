$PBExportHeader$b0u_dbmgr_v20.sru
$PBExportComments$[ohj] DB 접속
forward
global type b0u_dbmgr_v20 from u_cust_a_db
end type
end forward

global type b0u_dbmgr_v20 from u_cust_a_db
end type
global b0u_dbmgr_v20 b0u_dbmgr_v20

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();String ls_zoncod
Long   ll_cnt = 0, li_result
ii_rc = -1
Choose Case is_caller
	Case "b0w_inq_zoncst3_enddt_popup_v20%update"
//		lu_dbmgr.is_caller = "b0w_reg_standard_zone%display"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = data	

		ls_zoncod = is_data[3]		
      If isnull(ls_zoncod) Then ls_zoncod = ''
		
		ll_cnt = 0
		If ls_zoncod <> '' then
			select count(zoncod)
			  into :ll_cnt
			  from zoncst2
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and zoncod    = :is_data[3]
				and enddt     is null
				and opendt   <= :id_data[1] ;
		Else
			select count(zoncod)
			  into :ll_cnt
			  from zoncst2
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and enddt     is null
				and opendt   <= :id_data[1] ;
		End If
		If ll_cnt > 0 Then
			li_result = f_msg_ques_yesno2(9000,is_title, "해당하는 대역요율을 일괄종료처리 하시겠습니까? ", 2)
			If li_result = 2 Then
				Return
			End If
		Else
			f_msg_info(9000, is_title, "일괄종료처리 할 대역요율이 없습니다.")
			Return
		End If
		
		If ls_zoncod <> '' then
			update zoncst2 
			   set enddt     = :id_data[1]
				  , updtdt    = sysdate			  
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and zoncod    = :is_data[3]
				and enddt     is null
				and opendt   <= :id_data[1] ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "update zoncst2 Table")
				RollBack;
				Return
			End If				
		Else
			update zoncst2
			   set enddt     = :id_data[1]
				  , updtdt    = sysdate
			 where svccod    = :is_data[1]
				and priceplan = :is_data[2]
				and enddt     is null
				and opendt   <= :id_data[1] ;
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, "update zoncst2 Table zoncod all")
				RollBack;
				Return
			End If	
		End If
		
End Choose
ii_rc = 0
Return 
end subroutine

on b0u_dbmgr_v20.create
call super::create
end on

on b0u_dbmgr_v20.destroy
call super::destroy
end on

