$PBExportHeader$b1u_dbmgr2_vtel.sru
$PBExportComments$[parkkh] DB Manager
forward
global type b1u_dbmgr2_vtel from u_cust_a_db
end type
end forward

global type b1u_dbmgr2_vtel from u_cust_a_db
end type
global b1u_dbmgr2_vtel b1u_dbmgr2_vtel

type variables

end variables

forward prototypes
public subroutine uf_prc_db ()
end prototypes

public subroutine uf_prc_db ();
//"b1dw_inq_inv_detail_t1%tabpage_retrieve"
String ls_module, ls_ref_no, ls_ref_desc, ls_temp, ls_desc[], ls_result[]
Long ll_rows, ll_row
dec ldc_contractseq, ldc_orderno
Int  li_tmp, li_cnt, li_cnt2, li_st, li_st2
String ls_payid,  ls_content[]
String ls_reqnum, ls_reqnumBf, ls_trdt, ls_trdtBf, ls_trcodnm 
String ls_flag, ls_trcod , ls_sql, ls_table
Dec{2} lc0_seqno, lc0_remain, lc0_tramt, lc0_amt[]

// "b1w_reg_svcactprc%save"
String ls_next, ls_customerid, ls_activedt, ls_status, ls_svccod, ls_priceplan, ls_prmtype, ls_cus_status
String ls_reg_partner, ls_sale_partner, ls_maintain_partner, ls_settle_partner, ls_requestdt , ls_partner
String ls_validkey, ls_todt_tmp, ls_reg_prefixno, ls_remark, ls_svctype
String ls_bil_fromdt, ls_termtype, ls_contractno, ls_orderdt, ls_orderno, ls_pgm_id, ls_user_id, ls_term_status, ls_enter_status
Datetime ldt_crtdt
String ls_hotbillflag

Long ll_cnt

// "b1w_reg_svc_reactprc%save"
String ls_act_yn

String ls_trcod_tmp[], ls_reqnum_tmp[],ls_trdt_tmp[],ls_trcodnm_tmp[]
String ls_reqnum_sum[], ls_trdt_sum[]
Dec{2} lc0_trcod_amt[], lc0_tramt_sum[]
	
int li_i =0 ,li_reqnum_cnt, li_row_count, li_n, li_sum

ii_rc = -2

Choose Case is_caller
	Case "b1dw_inq_inv_detail_t1_vtel%tabpage_retrieve"
		// 2002.09.30, Park Kyung Hae: 월별청구내역 청구번호별 sum
		lc0_remain = 0
		ll_rows = 0
		ls_payid = is_data[1]
		idw_data[1].Reset()
		
		// SYSCTL1T의 청구항목 갯수 
		ls_module = "B1"
		ls_ref_no = "H100"
		ls_ref_desc = ""
		ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
		If ls_temp = "" Then Return 
		fi_cut_string(ls_temp, ";" , ls_result[])
		li_cnt = Integer(ls_result[1])
		
		For li_tmp = 1 To li_cnt
			If li_tmp < li_cnt Then
				ls_ref_no = "H1"
				If li_tmp < 10 Then 
					ls_ref_no = fs_fill_zeroes(ls_ref_no, 3)
				End If
				ls_ref_no += String(li_tmp)
				// SYSCTL1T의 청구항목
				ls_module = "B1"
				ls_ref_desc = ""
				ls_temp = fs_get_control(ls_module, ls_ref_no, ls_ref_desc)
				ls_content[li_tmp] = Trim(ls_temp)
				ls_desc[li_tmp] = ls_ref_desc
				
			ElseIf li_tmp = li_cnt Then 
				// 청구항목 마지막에 청구잔액
				ls_ref_desc = "청구요금"
			End If
			
			// 칼럼이름 셋팅
			Choose Case li_tmp
				Case 1
					idw_data[1].Object.amt_1_t.Text = ls_ref_desc
					idw_data[1].Object.amt_1.Visible = 1
					idw_data[1].Object.amt_1_t.Visible = 1
					idw_data[1].Object.amt_1_s.Visible = 1
				Case 2
					idw_data[1].Object.amt_2_t.Text = ls_ref_desc
					idw_data[1].Object.amt_2.Visible = 1
					idw_data[1].Object.amt_2_t.Visible = 1
					idw_data[1].Object.amt_2_s.Visible = 1
				Case 3
					idw_data[1].Object.amt_3_t.Text = ls_ref_desc
					idw_data[1].Object.amt_3.Visible = 1
					idw_data[1].Object.amt_3_t.Visible = 1
					idw_data[1].Object.amt_3_s.Visible = 1
				Case 4
					idw_data[1].Object.amt_4_t.Text = ls_ref_desc
					idw_data[1].Object.amt_4.Visible = 1
					idw_data[1].Object.amt_4_t.Visible = 1
					idw_data[1].Object.amt_4_s.Visible = 1
				Case 5
					idw_data[1].Object.amt_5_t.Text = ls_ref_desc
					idw_data[1].Object.amt_5.Visible = 1
					idw_data[1].Object.amt_5_t.Visible = 1
					idw_data[1].Object.amt_5_s.Visible = 1
				Case 6
					idw_data[1].Object.amt_6_t.Text = ls_ref_desc
					idw_data[1].Object.amt_6.Visible = 1
					idw_data[1].Object.amt_6_t.Visible = 1
					idw_data[1].Object.amt_6_s.Visible = 1
				Case 7
					idw_data[1].Object.amt_7_t.Text = ls_ref_desc
					idw_data[1].Object.amt_7.Visible = 1
					idw_data[1].Object.amt_7_t.Visible = 1
					idw_data[1].Object.amt_7_s.Visible = 1
				Case 8
					idw_data[1].Object.amt_8_t.Text = ls_ref_desc
					idw_data[1].Object.amt_8.Visible = 1
					idw_data[1].Object.amt_8_t.Visible = 1
					idw_data[1].Object.amt_8_s.Visible = 1
				Case 9
					idw_data[1].Object.amt_9_t.Text = ls_ref_desc
					idw_data[1].Object.amt_9.Visible = 1
					idw_data[1].Object.amt_9_t.Visible = 1
					idw_data[1].Object.amt_9_s.Visible = 1
				Case 10
					idw_data[1].Object.amt_10_t.Text = ls_ref_desc
					idw_data[1].Object.amt_10.Visible = 1
					idw_data[1].Object.amt_10_t.Visible = 1
					idw_data[1].Object.amt_10_s.Visible = 1
				Case 11
					idw_data[1].Object.amt_11_t.Text = ls_ref_desc
					idw_data[1].Object.amt_11.Visible = 1
					idw_data[1].Object.amt_11_t.Visible = 1
					idw_data[1].Object.amt_11_s.Visible = 1
				Case 12
					idw_data[1].Object.amt_12_t.Text = ls_ref_desc
					idw_data[1].Object.amt_12.Visible = 1
					idw_data[1].Object.amt_12_t.Visible = 1
					idw_data[1].Object.amt_12_s.Visible = 1
				Case 13
					idw_data[1].Object.amt_13_t.Text = ls_ref_desc
					idw_data[1].Object.amt_13.Visible = 1
					idw_data[1].Object.amt_13_t.Visible = 1
					idw_data[1].Object.amt_13_s.Visible = 1
				Case 14
					idw_data[1].Object.amt_14_t.Text = ls_ref_desc
					idw_data[1].Object.amt_14.Visible = 1
					idw_data[1].Object.amt_14_t.Visible = 1
					idw_data[1].Object.amt_14_s.Visible = 1
				Case 15
					idw_data[1].Object.amt_15_t.Text = ls_ref_desc
					idw_data[1].Object.amt_15.Visible = 1
					idw_data[1].Object.amt_15_t.Visible = 1
					idw_data[1].Object.amt_15_s.Visible = 1
				Case 16
					idw_data[1].Object.amt_16_t.Text = ls_ref_desc
					idw_data[1].Object.amt_16.Visible = 1
					idw_data[1].Object.amt_16_t.Visible = 1
					idw_data[1].Object.amt_16_s.Visible = 1
				Case 17
					idw_data[1].Object.amt_17_t.Text = ls_ref_desc
					idw_data[1].Object.amt_17.Visible = 1
					idw_data[1].Object.amt_17_t.Visible = 1
					idw_data[1].Object.amt_17_s.Visible = 1
				Case 18
					idw_data[1].Object.amt_18_t.Text = ls_ref_desc
					idw_data[1].Object.amt_18.Visible = 1
					idw_data[1].Object.amt_18_t.Visible = 1
					idw_data[1].Object.amt_18_s.Visible = 1
				Case 19
					idw_data[1].Object.amt_19_t.Text = ls_ref_desc
					idw_data[1].Object.amt_19.Visible = 1
					idw_data[1].Object.amt_19_t.Visible = 1
					idw_data[1].Object.amt_19_s.Visible = 1
				Case 20
					idw_data[1].Object.amt_20_t.Text = ls_ref_desc
					idw_data[1].Object.amt_20.Visible = 1
					idw_data[1].Object.amt_20_t.Visible = 1
					idw_data[1].Object.amt_20_s.Visible = 1
				Case 21
					idw_data[1].Object.amt_21_t.Text = ls_ref_desc
					idw_data[1].Object.amt_21.Visible = 1
					idw_data[1].Object.amt_21_t.Visible = 1
					idw_data[1].Object.amt_21_s.Visible = 1
				Case 22
					idw_data[1].Object.amt_22_t.Text = ls_ref_desc
					idw_data[1].Object.amt_22.Visible = 1
					idw_data[1].Object.amt_22_t.Visible = 1
					idw_data[1].Object.amt_22_s.Visible = 1
				Case 23
					idw_data[1].Object.amt_23_t.Text = ls_ref_desc
					idw_data[1].Object.amt_23.Visible = 1
					idw_data[1].Object.amt_23_t.Visible = 1
					idw_data[1].Object.amt_23_s.Visible = 1
				Case 24
					idw_data[1].Object.amt_24_t.Text = ls_ref_desc
					idw_data[1].Object.amt_24.Visible = 1
					idw_data[1].Object.amt_24_t.Visible = 1
					idw_data[1].Object.amt_24_s.Visible = 1
				Case 25
					idw_data[1].Object.amt_25_t.Text = ls_ref_desc
					idw_data[1].Object.amt_25.Visible = 1
					idw_data[1].Object.amt_25_t.Visible = 1
					idw_data[1].Object.amt_25_s.Visible = 1
				Case 26
					idw_data[1].Object.amt_26_t.Text = ls_ref_desc
					idw_data[1].Object.amt_26.Visible = 1
					idw_data[1].Object.amt_26_t.Visible = 1
					idw_data[1].Object.amt_26_s.Visible = 1
				Case 27
					idw_data[1].Object.amt_27_t.Text = ls_ref_desc
					idw_data[1].Object.amt_27.Visible = 1
					idw_data[1].Object.amt_27_t.Visible = 1
					idw_data[1].Object.amt_27_s.Visible = 1
				Case 28
					idw_data[1].Object.amt_28_t.Text = ls_ref_desc
					idw_data[1].Object.amt_28.Visible = 1
					idw_data[1].Object.amt_28_t.Visible = 1
					idw_data[1].Object.amt_28_s.Visible = 1
				Case 29
					idw_data[1].Object.amt_29_t.Text = ls_ref_desc
					idw_data[1].Object.amt_29.Visible = 1
					idw_data[1].Object.amt_29_t.Visible = 1
					idw_data[1].Object.amt_29_s.Visible = 1
				Case 30
					idw_data[1].Object.amt_30_t.Text = ls_ref_desc
					idw_data[1].Object.amt_30.Visible = 1
					idw_data[1].Object.amt_30_t.Visible = 1
					idw_data[1].Object.amt_30_s.Visible = 1
		End Choose
			lc0_amt[li_tmp] = 0
		Next
		
     //TABLE SETTING : TAB1 일때랑 TAB2 일때 가져오는 테이블이 다르다.
		If is_data[2] = "1" Then
			ls_table = "reqdtl"
		ElseIf is_data[2] = "2" Then
			ls_table = "reqdtlh"
		End if
			
		ls_sql = " SELECT a.reqnum, to_char(a.trdt,'yyyymmdd'), a.trcod, b.trcodnm, sum(a.tramt) " + &
					 " FROM " + ls_table + " a, trcode b  " + &
					 " WHERE a.trcod = b.trcod " + &
					 "  AND  a.PAYID = '" + ls_payid + "'" + &
					 "  AND  ( a.mark is null or a.mark <> 'D') " + &
					 " GROUP BY a.reqnum, to_char(a.trdt,'yyyymmdd'), a.trcod, b.trcodnm " + &
					 " ORDER BY 2 DESC, 1 DESC "

		DECLARE cur_read_reqdtl DYNAMIC CURSOR FOR SQLSA;
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC	cur_read_reqdtl;
		
		If  sqlca.sqlcode = -1 Then
			 clipboard(ls_sql)	 
			 f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl")
			 Close cur_read_reqdtl;
			 Return 
		End If
		
		DO WHILE TRUE
			Fetch cur_read_reqdtl
			Into :ls_reqnum, :ls_trdt, :ls_trcod, :ls_trcodnm, :lc0_tramt;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl")
				Close cur_read_reqdtl;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				If ll_rows = 0 Then Exit
			End If
			li_i +=1
			ls_reqnum_tmp[li_i]   = ls_reqnum
			ls_trdt_tmp  [li_i]   = ls_trdt
		   ls_trcod_tmp [li_i]   = ls_trcod
			ls_trcodnm_tmp[li_i]  = ls_trcodnm
			lc0_trcod_amt[li_i]   = lc0_tramt			
		Loop
		Close cur_read_reqdtl;

     //======================================================================
		ls_sql = " SELECT reqnum, to_char(trdt,'yyyymmdd'), sum(tramt) " + &
					 " FROM " + ls_table  + &
					 " WHERE  PAYID = '" + ls_payid + "'" + &
					 "  AND  ( mark is null or mark <> 'D') " + &
					 " GROUP BY reqnum, to_char(trdt,'yyyymmdd')" + &
					 " ORDER BY 2 DESC, 1 DESC "

		DECLARE cur_read_reqdtl_sum DYNAMIC CURSOR FOR SQLSA;
		PREPARE SQLSA FROM :ls_sql;
		OPEN DYNAMIC	cur_read_reqdtl_sum;
		
		If  sqlca.sqlcode = -1 Then
			 clipboard(ls_sql)	 
			 f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl_sum")
			 Close cur_read_reqdtl_sum;
			 Return 
		End If
		
		DO WHILE TRUE
			Fetch cur_read_reqdtl_sum
			Into :ls_reqnum, :ls_trdt, :lc0_tramt;
			
			If SQLCA.SQLCode < 0 Then
				f_msg_sql_err(is_title, is_caller + " : cur_read_reqdtl_sum")
				Close cur_read_reqdtl_sum;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				If ll_rows = 0 Then Exit
			End If
			li_sum +=1
			ls_reqnum_sum[li_sum]   = ls_reqnum
			ls_trdt_sum  [li_sum]   = ls_trdt
			lc0_tramt_sum[li_sum]   = lc0_tramt
		Loop
		Close cur_read_reqdtl_sum;		
				

		//이전 청구번호에 해당하는 거래내역 입력
		For li_row_count=1 To li_i

			If ls_reqnumBf <> ls_reqnum_tmp[li_row_count]Then					
				ls_reqnum = ls_reqnum_tmp[li_row_count]
				ls_trdt = ls_trdt_tmp[li_row_count]											
			End If						

			If ls_reqnumBf = ls_reqnum_tmp[li_row_count] Then

				For li_tmp = 1 To li_cnt 
					// 마지막항목은 청구잔액
					If li_tmp = li_cnt Then 
						lc0_amt[li_tmp] = lc0_remain
					End If
					Choose Case li_tmp
						Case 1
							idw_data[1].Object.amt_1[ll_row] = lc0_amt[li_tmp]
						Case 2
							idw_data[1].Object.amt_2[ll_row] = lc0_amt[li_tmp]
						Case 3
							idw_data[1].Object.amt_3[ll_row] = lc0_amt[li_tmp]
						Case 4
							idw_data[1].Object.amt_4[ll_row] = lc0_amt[li_tmp]
						Case 5
							idw_data[1].Object.amt_5[ll_row] = lc0_amt[li_tmp]
						Case 6
							idw_data[1].Object.amt_6[ll_row] = lc0_amt[li_tmp]
						Case 7
							idw_data[1].Object.amt_7[ll_row] = lc0_amt[li_tmp]
						Case 8
							idw_data[1].Object.amt_8[ll_row] = lc0_amt[li_tmp]
						Case 9
							idw_data[1].Object.amt_9[ll_row] = lc0_amt[li_tmp]
						Case 10
							idw_data[1].Object.amt_10[ll_row] = lc0_amt[li_tmp]
						Case 11
							idw_data[1].Object.amt_11[ll_row] = lc0_amt[li_tmp]
						Case 12
							idw_data[1].Object.amt_12[ll_row] = lc0_amt[li_tmp]
						Case 13
							idw_data[1].Object.amt_13[ll_row] = lc0_amt[li_tmp]
						Case 14
							idw_data[1].Object.amt_14[ll_row] = lc0_amt[li_tmp]
						Case 15
							idw_data[1].Object.amt_15[ll_row] = lc0_amt[li_tmp]
						Case 16
							idw_data[1].Object.amt_16[ll_row] = lc0_amt[li_tmp]
						Case 17
							idw_data[1].Object.amt_17[ll_row] = lc0_amt[li_tmp]
						Case 18
							idw_data[1].Object.amt_18[ll_row] = lc0_amt[li_tmp]
						Case 19
							idw_data[1].Object.amt_19[ll_row] = lc0_amt[li_tmp]
						Case 20
							idw_data[1].Object.amt_20[ll_row] = lc0_amt[li_tmp]
						Case 21
							idw_data[1].Object.amt_21[ll_row] = lc0_amt[li_tmp]
						Case 22
							idw_data[1].Object.amt_22[ll_row] = lc0_amt[li_tmp]
						Case 23
							idw_data[1].Object.amt_23[ll_row] = lc0_amt[li_tmp]
						Case 24
							idw_data[1].Object.amt_24[ll_row] = lc0_amt[li_tmp]
						Case 25
							idw_data[1].Object.amt_25[ll_row] = lc0_amt[li_tmp]
						Case 26
							idw_data[1].Object.amt_26[ll_row] = lc0_amt[li_tmp]
						Case 27
							idw_data[1].Object.amt_27[ll_row] = lc0_amt[li_tmp]
						Case 28
							idw_data[1].Object.amt_28[ll_row] = lc0_amt[li_tmp]
						Case 29
							idw_data[1].Object.amt_29[ll_row] = lc0_amt[li_tmp]
						Case 30
							idw_data[1].Object.amt_30[ll_row] = lc0_amt[li_tmp]							
					End Choose
				Next		


				For li_tmp = 1 To li_cnt - 1
					//SYSCTL1T의 청구항목 - 미리 배열에 저장된 값을 읽음
					lc0_amt[li_tmp] = 0
					ls_temp = Trim(ls_content[li_tmp])
					If IsNull(ls_temp) Then ls_temp = ""
					If ls_temp = "" Then Return 
					li_cnt2 = fi_cut_string(ls_temp, ";" , ls_result[])
					For li_st2 = 2 To	li_cnt2
						For li_n =1 To li_i
							If ls_reqnumBf = ls_reqnum_tmp[li_n] Then
							If ls_trcod_tmp[li_n] = ls_result[li_st2] Then								
								lc0_tramt =lc0_trcod_amt[li_n]
								//lc0_remain += lc0_tramt
								//lc0_amt[li_tmp] += ABS(lc0_tramt)
								lc0_amt[li_tmp] += lc0_tramt
							// For Loop 완전히 빠져 나가도록
								//li_tmp = li_cnt
								//Exit
							End If
						End If
						Next
					Next					
				Next
			For li_tmp=1 To li_sum 
				If ls_reqnumBf = ls_reqnum_sum[li_tmp] Then
					lc0_remain = lc0_tramt_sum[li_tmp]
				End If
			Next
		Else
			//이전 청구번호에 해당하는 거래내역 입력
			ll_row = idw_data[1].InsertRow(0)							
			idw_data[1].Object.trdt[ll_row] = ls_trdt
			idw_data[1].Object.reqnum[ll_row] = ls_reqnum
			For li_tmp = 1 To li_cnt
				// 마지막항목은 청구잔액
				If li_tmp = li_cnt Then 
					lc0_amt[li_tmp] = lc0_remain
				End If
				Choose Case li_tmp
					Case 1
						idw_data[1].Object.amt_1[ll_row] = lc0_amt[li_tmp]
					Case 2
						idw_data[1].Object.amt_2[ll_row] = lc0_amt[li_tmp]
					Case 3
						idw_data[1].Object.amt_3[ll_row] = lc0_amt[li_tmp]
					Case 4
						idw_data[1].Object.amt_4[ll_row] = lc0_amt[li_tmp]
					Case 5
						idw_data[1].Object.amt_5[ll_row] = lc0_amt[li_tmp]
					Case 6
						idw_data[1].Object.amt_6[ll_row] = lc0_amt[li_tmp]
					Case 7
						idw_data[1].Object.amt_7[ll_row] = lc0_amt[li_tmp]
					Case 8
						idw_data[1].Object.amt_8[ll_row] = lc0_amt[li_tmp]
					Case 9
						idw_data[1].Object.amt_9[ll_row] = lc0_amt[li_tmp]
					Case 10
						idw_data[1].Object.amt_10[ll_row] = lc0_amt[li_tmp]
					Case 11
						idw_data[1].Object.amt_11[ll_row] = lc0_amt[li_tmp]
					Case 12
						idw_data[1].Object.amt_12[ll_row] = lc0_amt[li_tmp]
					Case 13
						idw_data[1].Object.amt_13[ll_row] = lc0_amt[li_tmp]
					Case 14
						idw_data[1].Object.amt_14[ll_row] = lc0_amt[li_tmp]
					Case 15
						idw_data[1].Object.amt_15[ll_row] = lc0_amt[li_tmp]
					Case 16
						idw_data[1].Object.amt_16[ll_row] = lc0_amt[li_tmp]
					Case 17
						idw_data[1].Object.amt_17[ll_row] = lc0_amt[li_tmp]
					Case 18
						idw_data[1].Object.amt_18[ll_row] = lc0_amt[li_tmp]
					Case 19
						idw_data[1].Object.amt_19[ll_row] = lc0_amt[li_tmp]
					Case 20
						idw_data[1].Object.amt_20[ll_row] = lc0_amt[li_tmp]
					Case 21
						idw_data[1].Object.amt_21[ll_row] = lc0_amt[li_tmp]
					Case 22
						idw_data[1].Object.amt_22[ll_row] = lc0_amt[li_tmp]
					Case 23
						idw_data[1].Object.amt_23[ll_row] = lc0_amt[li_tmp]
					Case 24
						idw_data[1].Object.amt_24[ll_row] = lc0_amt[li_tmp]
					Case 25
						idw_data[1].Object.amt_25[ll_row] = lc0_amt[li_tmp]
					Case 26
						idw_data[1].Object.amt_26[ll_row] = lc0_amt[li_tmp]
					Case 27
						idw_data[1].Object.amt_27[ll_row] = lc0_amt[li_tmp]
					Case 28
						idw_data[1].Object.amt_28[ll_row] = lc0_amt[li_tmp]
					Case 29
						idw_data[1].Object.amt_29[ll_row] = lc0_amt[li_tmp]
					Case 30
						idw_data[1].Object.amt_30[ll_row] = lc0_amt[li_tmp]							
				End Choose
				lc0_amt[li_tmp] = 0					
			Next
			lc0_remain = 0
						
			For li_tmp = 1 To li_cnt - 1
				//SYSCTL1T의 청구항목 - 미리 배열에 저장된 값을 읽음
				lc0_amt[li_tmp] = 0
				ls_temp = Trim(ls_content[li_tmp])
				If IsNull(ls_temp) Then ls_temp = ""
				If ls_temp = "" Then Return 
				li_cnt2 = fi_cut_string(ls_temp, ";" , ls_result[])
				For li_st2 = 2 To	li_cnt2
					For li_n = 1 To li_i step 1
						If ls_reqnum = ls_reqnum_tmp[li_n] Then
							If ls_trcod_tmp[li_n] = ls_result[li_st2] Then								
								lc0_tramt =lc0_trcod_amt[li_n]
								//lc0_remain += lc0_tramt
								//lc0_amt[li_tmp] += ABS(lc0_tramt)
								lc0_amt[li_tmp] += lc0_tramt							
								// For Loop 완전히 빠져 나가도록
								//li_tmp = li_cnt
								//Exit
							End If				
						End If
					Next
				Next
			Next
			
		End If			
		
		ls_reqnumBf = ls_reqnum
		ls_trdtBf = ls_trdt
	Next
		

	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
		
End Choose

ii_rc = 0


end subroutine

on b1u_dbmgr2_vtel.create
call super::create
end on

on b1u_dbmgr2_vtel.destroy
call super::destroy
end on

