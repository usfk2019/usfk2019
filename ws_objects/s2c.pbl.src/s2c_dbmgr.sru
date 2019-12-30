$PBExportHeader$s2c_dbmgr.sru
$PBExportComments$[cesee] DB 접근
forward
global type s2c_dbmgr from u_cust_a_db
end type
end forward

global type s2c_dbmgr from u_cust_a_db
end type
global s2c_dbmgr s2c_dbmgr

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();Long i, j, ll_user_cnt
Integer li_pre_cnt, li_post_cnt
String ls_type, ls_priceplan, ls_yyyymmdd, ls_partner
String ls_ref_desc, ls_post[], ls_pre[], ls_temp
String ls_svctype
ii_rc = -1
Choose Case is_caller
	Case "s2w_prt_priceplan%ok"
		
		//선/후불 Type
		ls_temp = fs_get_control("B1", "P211", ls_ref_desc)  //선불 
		li_pre_cnt = fi_cut_string(ls_temp, ";", ls_pre[])
		ls_temp = fs_get_control("B1", "P212", ls_ref_desc)  //후불 
		li_post_cnt = fi_cut_string(ls_temp, ";", ls_post[])
		ls_svctype = ""
		
		//해당 Row에서 조건 가져오기
		For i = 1 To idw_data[1].RowCount()
			ls_yyyymmdd = idw_data[1].object.workdt[i]
			ls_priceplan = idw_data[1].object.priceplan[i]
			ls_type = idw_data[1].object.type[i]
			
			//선/후불 구불
			If ls_svctype = "" Then
			For j=1 To li_pre_cnt
				If ls_type = ls_pre[j] Then
					ls_svctype = "PRE"
					exit;
				End If
				ls_svctype = ""
			Next
			 End If
			If ls_svctype = "" Then
			For j=1 To li_post_cnt
				If ls_type = ls_post[j] Then
					ls_svctype = "POST"
					exit;
				End If
				ls_svctype = ""
			Next
		  End If
			
	      If ls_svctype = "POST" Then
			
			   select count(distinct customerid)
				Into :ll_user_cnt
				From post_bilcdr
				where workdt >= to_date(:ls_yyyymmdd, 'yyyymmdd')
				and	workdt <= to_date(:ls_yyyymmdd, 'yyyymmdd') + 0.99999
				and 	priceplan = :ls_priceplan;
				//group by workdt, priceplan;
				
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller+" Select post_bilcdr")				
					Return 
				End If
			Else
				select count(distinct pid)
				Into :ll_user_cnt
				From pre_bilcdr
				where workdt >= to_date(:ls_yyyymmdd, 'yyyymmdd')
				and	workdt <= to_date(:ls_yyyymmdd, 'yyyymmdd') + 0.99999
				and 	priceplan = :ls_priceplan;
				//group by workdt, priceplan;
				
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller+" Select pre_bilcdr")				
					Return 
				End If
			End If
			//Setting
			idw_data[1].object.sum_user[i] = ll_user_cnt 
			ll_user_cnt = 0
			ls_svctype = ""
		Next
	Case "s2w_prt_partner%ok"
		
		//선/후불 Type
		ls_temp = fs_get_control("B1", "P211", ls_ref_desc)  //선불 
		li_pre_cnt = fi_cut_string(ls_temp, ";", ls_pre[])
		ls_temp = fs_get_control("B1", "P212", ls_ref_desc)  //후불 
		li_post_cnt = fi_cut_string(ls_temp, ";", ls_post[])
		ls_svctype = ""
		
		//해당 Row에서 조건 가져오기
		For i = 1 To idw_data[1].RowCount()
			ls_yyyymmdd = idw_data[1].object.workdt[i]
			ls_partner = idw_data[1].object.sale_partner[i]
			ls_type = idw_data[1].object.type[i]
			
			//선/후불 구불
			If ls_svctype = "" Then
			For j=1 To li_pre_cnt
				If ls_type = ls_pre[j] Then
					ls_svctype = "PRE"
					exit;
				End If
				ls_svctype = ""
			Next
			 End If
			If ls_svctype = "" Then
			For j=1 To li_post_cnt
				If ls_type = ls_post[j] Then
					ls_svctype = "POST"
					exit;
				End If
				ls_svctype = ""
			Next
		  End If
			
	      If ls_svctype = "POST" Then
			
			   select count(distinct customerid)
				Into :ll_user_cnt
				From post_bilcdr
				where workdt >= to_date(:ls_yyyymmdd, 'yyyymmdd')
				and	workdt <= to_date(:ls_yyyymmdd, 'yyyymmdd') + 0.99999
				and 	partner = :ls_partner;
				//group by workdt, priceplan;
				
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller+" Select post_bilcdr")				
					Return 
				End If
			Else
				select count(distinct pid)
				Into :ll_user_cnt
				From pre_bilcdr
				where workdt >= to_date(:ls_yyyymmdd, 'yyyymmdd')
				and	workdt <= to_date(:ls_yyyymmdd, 'yyyymmdd') + 0.99999
				and 	partner = :ls_partner;
				//group by workdt, priceplan;
				
				If sqlca.sqlcode < 0 Then
					f_msg_sql_err(is_title, is_caller+" Select pre_bilcdr")				
					Return 
				End If
			End If
			//Setting
			idw_data[1].object.sum_user[i] = ll_user_cnt 
			ll_user_cnt = 0
			ls_svctype = ""
		Next			
End Choose
ii_rc = 0
Return

end subroutine

on s2c_dbmgr.create
call super::create
end on

on s2c_dbmgr.destroy
call super::destroy
end on

