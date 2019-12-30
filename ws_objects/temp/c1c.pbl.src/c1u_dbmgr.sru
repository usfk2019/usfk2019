$PBExportHeader$c1u_dbmgr.sru
$PBExportComments$[ssong] DB Manager
forward
global type c1u_dbmgr from u_cust_a_db
end type
end forward

global type c1u_dbmgr from u_cust_a_db
end type
global c1u_dbmgr c1u_dbmgr

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();Long ll_tmp, ll_count = 0, ll_row, ll_row_bf
Int  li_rc, li_count
Dec lc_data
DateTime ldt_sysdate
String ls_ref_desc, ls_temp, ls_result[], ls_cur_name

//parkkh: "c1w_prt_carrier_callsum%ue_ok"
String ls_carriertype, ls_carrierid, ls_carriernm, ls_carrier, ls_carriertype_bf, ls_carrierid_bf
Dec{0} ldc_biltime, ldc_biltime_sum
Int li_workdt

ii_rc = -1

Choose Case is_caller
	Case "c1w_prt_carrier_callsum%ue_ok"
//		 WINDOW : c1w_prt_carrier_callsum
//		 작성자 : 2003년 06월 19일 박경해 T&C Technology
//		 목  적 : 사업자별 통화량 현황
//		 인  자 :	
//					lu_dbmgr.is_caller = "c1w_prt_carrier_callsum%ue_ok"
//					lu_dbmgr.is_title = Title
//					lu_dbmgr.idw_data[1] = dw_list
//					lu_dbmgr.is_data[1]  = ls_yyyymm

		
		idw_data[1].reset()
		ll_row_bf = 0
		ls_carriertype_bf = ""
		ls_carrierid_bf = ""
		
		DECLARE cur_callsum CURSOR FOR
		select  mst.carriertype,
				amt.carrierid, 
			    mst.carriernm,
			    to_number(to_char(amt.workdt,'dd')) workdt,
//		        trunc(sum(nvl(amt.biltime,0)),0) biltime
		        trunc(sum(nvl(amt.biltime/60,0)),0) biltime				
		  from carrier_mst mst, carrier_amount amt
		 where mst.carrierid = amt.carrierid
		   and to_char(workdt,'yyyymm') = :is_data[1]
		group by mst.carriertype, amt.carrierid, mst.carriernm, to_char(amt.workdt,'dd')
		order by mst.carriertype, amt.carrierid, mst.carriernm, to_char(amt.workdt,'dd');
		
		OPEN cur_callsum; 
		Do While (True)
			Fetch cur_callsum
			Into :ls_carriertype,
			     :ls_carrierid,
				 :ls_carriernm,
				 :li_workdt,
				 :ldc_biltime;
				 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_callsum")
				Close cur_callsum;
				Return
			ElseIf SQLCA.SQLCode = 100 Then				
				Exit
			End If
			
			If ls_carrierid_bf <> ls_carrierid Then
				ll_row_bf = ll_row
				ll_row = idw_data[1].insertrow(0)
				ls_carriertype_bf = ls_carriertype
				ls_carrierid_bf = ls_carrierid
				idw_data[1].Object.carriertype[ll_row]  = ls_carriertype
				idw_data[1].Object.carrierid[ll_row]  = ls_carrierid
				idw_data[1].Object.carriernm[ll_row]  = ls_carriernm
				If ll_row <> 1 Then	idw_data[1].Object.biltime_sum[ll_row_bf]  = ldc_biltime_sum
				ldc_biltime_sum = 0
			End If
			
			Choose Case li_workdt
				Case 1
					idw_data[1].Object.biltime_1[ll_row] = ldc_biltime
				Case 2
					idw_data[1].Object.biltime_2[ll_row] = ldc_biltime
				Case 3
					idw_data[1].Object.biltime_3[ll_row] = ldc_biltime
				Case 4
					idw_data[1].Object.biltime_4[ll_row] = ldc_biltime
				Case 5
					idw_data[1].Object.biltime_5[ll_row] = ldc_biltime
				Case 6
					idw_data[1].Object.biltime_6[ll_row] = ldc_biltime
				Case 7
					idw_data[1].Object.biltime_7[ll_row] = ldc_biltime
				Case 8
					idw_data[1].Object.biltime_8[ll_row] = ldc_biltime
				Case 9
					idw_data[1].Object.biltime_9[ll_row] = ldc_biltime
				Case 10
					idw_data[1].Object.biltime_10[ll_row] = ldc_biltime
				Case 11
					idw_data[1].Object.biltime_11[ll_row] = ldc_biltime
				Case 12
					idw_data[1].Object.biltime_12[ll_row] = ldc_biltime
				Case 13
					idw_data[1].Object.biltime_13[ll_row] = ldc_biltime
				Case 14
					idw_data[1].Object.biltime_14[ll_row] = ldc_biltime
				Case 15
					idw_data[1].Object.biltime_15[ll_row] = ldc_biltime
				Case 16
					idw_data[1].Object.biltime_16[ll_row] = ldc_biltime
				Case 17
					idw_data[1].Object.biltime_17[ll_row] = ldc_biltime
				Case 18
					idw_data[1].Object.biltime_18[ll_row] = ldc_biltime
				Case 19
					idw_data[1].Object.biltime_19[ll_row] = ldc_biltime
				Case 20
					idw_data[1].Object.biltime_20[ll_row] = ldc_biltime
				Case 21
					idw_data[1].Object.biltime_21[ll_row] = ldc_biltime
				Case 22
					idw_data[1].Object.biltime_22[ll_row] = ldc_biltime
				Case 23
					idw_data[1].Object.biltime_23[ll_row] = ldc_biltime
				Case 24
					idw_data[1].Object.biltime_24[ll_row] = ldc_biltime
				Case 25
					idw_data[1].Object.biltime_25[ll_row] = ldc_biltime
				Case 26
					idw_data[1].Object.biltime_26[ll_row] = ldc_biltime
				Case 27
					idw_data[1].Object.biltime_27[ll_row] = ldc_biltime
				Case 28
					idw_data[1].Object.biltime_28[ll_row] = ldc_biltime
				Case 29
					idw_data[1].Object.biltime_29[ll_row] = ldc_biltime
				Case 30
					idw_data[1].Object.biltime_30[ll_row] = ldc_biltime							
				Case 31
					idw_data[1].Object.biltime_31[ll_row] = ldc_biltime							
			End Choose
			
			ldc_biltime_sum += ldc_biltime
			
		Loop
	    Close cur_callsum;			

	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0

end subroutine

public subroutine uf_prc_db_01 ();Long ll_tmp, ll_count = 0, ll_row, ll_row_bf
Int  li_rc, li_count
Dec lc_data
DateTime ldt_sysdate
String ls_ref_desc, ls_temp, ls_result[], ls_cur_name

//ssong: "c1w_prt_carrier_callsum_bef%ue_ok"
String ls_carriertype, ls_carrierid, ls_carriernm, ls_carrier, ls_carriertype_bf, ls_carrierid_bf
Dec{0} ldc_biltime, ldc_biltime_sum
Int li_workdt

ii_rc = -1

Choose Case is_caller
	Case "c1w_prt_carrier_callsum_bef%ue_ok"
//		 WINDOW : c1w_prt_carrier_callsum_bef
//		 작성자 : 2005년 11월 09일 송은미 T&C Technology
//		 목  적 : 사업자별 통화량 현황
//		 인  자 :	
//					lu_dbmgr.is_caller = "c1w_prt_carrier_callsum_bef%ue_ok"
//					lu_dbmgr.is_title = Title
//					lu_dbmgr.idw_data[1] = dw_list
//					lu_dbmgr.is_data[1]  = ls_yyyymm

		
		idw_data[1].reset()
		ll_row_bf = 0
		ls_carriertype_bf = ""
		ls_carrierid_bf = ""
		
		DECLARE cur_callsum CURSOR FOR
		select  mst.carriertype
		     ,  amt.carrierid
			  ,  mst.carriernm
			  ,  to_number(to_char(amt.workdt,'dd')) workdt
			  ,
//		        trunc(sum(nvl(amt.biltime,0)),0) biltime
		        trunc(sum(nvl(amt.biltime/60,0)),0) biltime				
		  from carrier_mst mst, carrier_amount amt
		 where mst.carrierid = amt.carrierid
		   and to_char(workdt,'yyyymm') = :is_data[1]
		group by mst.carriertype, amt.carrierid, mst.carriernm, to_char(amt.workdt,'dd')
		order by mst.carriertype, amt.carrierid, mst.carriernm, to_char(amt.workdt,'dd');
		
		OPEN cur_callsum; 
		Do While (True)
			Fetch cur_callsum
			Into :ls_carriertype,
			     :ls_carrierid,
				 :ls_carriernm,
				 :li_workdt,
				 :ldc_biltime;
				 
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_callsum")
				Close cur_callsum;
				Return
			ElseIf SQLCA.SQLCode = 100 Then				
				Exit
			End If
			
			If ls_carrierid_bf <> ls_carrierid Then
				ll_row_bf = ll_row
				ll_row = idw_data[1].insertrow(0)
				ls_carriertype_bf = ls_carriertype
				ls_carrierid_bf = ls_carrierid
				idw_data[1].Object.carriertype[ll_row]  = ls_carriertype
				idw_data[1].Object.carrierid[ll_row]  = ls_carrierid
				idw_data[1].Object.carriernm[ll_row]  = ls_carriernm
				If ll_row <> 1 Then	idw_data[1].Object.biltime_sum[ll_row_bf]  = ldc_biltime_sum
				ldc_biltime_sum = 0
			End If
			
			Choose Case li_workdt
				Case 1
					idw_data[1].Object.biltime_1[ll_row] = ldc_biltime
				Case 2
					idw_data[1].Object.biltime_2[ll_row] = ldc_biltime
				Case 3
					idw_data[1].Object.biltime_3[ll_row] = ldc_biltime
				Case 4
					idw_data[1].Object.biltime_4[ll_row] = ldc_biltime
				Case 5
					idw_data[1].Object.biltime_5[ll_row] = ldc_biltime
				Case 6
					idw_data[1].Object.biltime_6[ll_row] = ldc_biltime
				Case 7
					idw_data[1].Object.biltime_7[ll_row] = ldc_biltime
				Case 8
					idw_data[1].Object.biltime_8[ll_row] = ldc_biltime
				Case 9
					idw_data[1].Object.biltime_9[ll_row] = ldc_biltime
				Case 10
					idw_data[1].Object.biltime_10[ll_row] = ldc_biltime
				Case 11
					idw_data[1].Object.biltime_11[ll_row] = ldc_biltime
				Case 12
					idw_data[1].Object.biltime_12[ll_row] = ldc_biltime
				Case 13
					idw_data[1].Object.biltime_13[ll_row] = ldc_biltime
				Case 14
					idw_data[1].Object.biltime_14[ll_row] = ldc_biltime
				Case 15
					idw_data[1].Object.biltime_15[ll_row] = ldc_biltime
				Case 16
					idw_data[1].Object.biltime_16[ll_row] = ldc_biltime
				Case 17
					idw_data[1].Object.biltime_17[ll_row] = ldc_biltime
				Case 18
					idw_data[1].Object.biltime_18[ll_row] = ldc_biltime
				Case 19
					idw_data[1].Object.biltime_19[ll_row] = ldc_biltime
				Case 20
					idw_data[1].Object.biltime_20[ll_row] = ldc_biltime
				Case 21
					idw_data[1].Object.biltime_21[ll_row] = ldc_biltime
				Case 22
					idw_data[1].Object.biltime_22[ll_row] = ldc_biltime
				Case 23
					idw_data[1].Object.biltime_23[ll_row] = ldc_biltime
				Case 24
					idw_data[1].Object.biltime_24[ll_row] = ldc_biltime
				Case 25
					idw_data[1].Object.biltime_25[ll_row] = ldc_biltime
				Case 26
					idw_data[1].Object.biltime_26[ll_row] = ldc_biltime
				Case 27
					idw_data[1].Object.biltime_27[ll_row] = ldc_biltime
				Case 28
					idw_data[1].Object.biltime_28[ll_row] = ldc_biltime
				Case 29
					idw_data[1].Object.biltime_29[ll_row] = ldc_biltime
				Case 30
					idw_data[1].Object.biltime_30[ll_row] = ldc_biltime							
				Case 31
					idw_data[1].Object.biltime_31[ll_row] = ldc_biltime							
			End Choose
			
			ldc_biltime_sum += ldc_biltime
			
		Loop
	    Close cur_callsum;			

	Case Else
		f_msg_info_app(9000, "uf_prc_db_app.uf_prc_db_01()", &
		 "Matching statement Not found.(" + String(is_caller) + ")")

End Choose

ii_rc = 0

end subroutine

on c1u_dbmgr.create
call super::create
end on

on c1u_dbmgr.destroy
call super::destroy
end on

