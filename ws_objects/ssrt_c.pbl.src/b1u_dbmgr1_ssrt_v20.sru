$PBExportHeader$b1u_dbmgr1_ssrt_v20.sru
$PBExportComments$[1hera] DBmanager
forward
global type b1u_dbmgr1_ssrt_v20 from u_cust_a_db
end type
end forward

global type b1u_dbmgr1_ssrt_v20 from u_cust_a_db
end type
global b1u_dbmgr1_ssrt_v20 b1u_dbmgr1_ssrt_v20

type variables
String 	is_customerid, is_customernm, &
			is_saledt, 		is_partner,		&
			is_operator,	is_userid, 		 &
			is_appseq, 		is_memberid
DEC{2}	idec_cash,		idec_change,	idec_total, 		idec_saleamt
Long		il_adseq,		il_payseq,		il_row,		il_shopcount, il_keynum
date		idt_saledt

String 	is_itemcod, 	is_regcod, is_basecod, is_payid, &
			is_itemnm, 		is_facnum,		is_contno, is_val
String 	is_paymethod[], is_method
dec{2}	idc_amt[], idc_rem
Integer  ii_amt_su,	ii_method, ii_paycnt
end variables

forward prototypes
public subroutine uf_prc_db_07 ()
end prototypes

public subroutine uf_prc_db_07 ();//ssrt 장비판매관리

Integer	i, jj, li_first, li_pp
dec{2}	ldc_salerem, ldc_saleamt, ldc_amt0[]
String 	ls_temp, ls_method0[], ls_restore

ii_rc = -1
li_first = 0
Choose Case is_caller
	Case "ssrt_reg_adsale_sams%save"  

    	is_memberid   		= Trim(idw_data[1].object.memberid[1])
    	is_customerid   	= Trim(idw_data[1].object.customerid[1])
		is_customernm    	= Trim(idw_data[1].object.customernm[1])
		idt_saledt      	= idw_data[1].object.saledt[1]
		is_partner    		= Trim(idw_data[1].object.partner[1])
		is_operator   		= Trim(idw_data[1].object.operator[1])
		is_userid      	= is_data[1]
		is_pgm_id       	= is_data[2]
	
		idec_total   		= idw_data[3].object.total[1]
		idec_cash			= idw_data[3].object.cp_cash[1]
		idec_change   		= idw_data[3].object.cp_change[1]
		
		ls_method0[1] 	= idw_data[3].object.paymethod1[1]
		ls_method0[2] 	= idw_data[3].object.paymethod2[1]
		ls_method0[3] 	= idw_data[3].object.paymethod3[1]
		ls_method0[4] 	= idw_data[3].object.paymethod4[1]
		ls_method0[5] 	= idw_data[3].object.paymethod5[1]
		ldc_amt0[1] 	= idw_data[3].object.amt1[1]
		ldc_amt0[2] 	= idw_data[3].object.amt2[1]
		ldc_amt0[3] 	= idw_data[3].object.amt3[1]
		ldc_amt0[4] 	= idw_data[3].object.amt4[1]
		ldc_amt0[5] 	= idw_data[3].object.amt5[1]
		ii_amt_su = 0

		FOR i = 1 to 5
			IF idc_amt[i] > 0 THEN 
				ii_amt_su += 1 
				idc_amt[ii_amt_su] 		= ldc_amt0[i]
				is_paymethod[ii_amt_su] = ls_method0[i]
			end if
		NEXT
		
		
		
		IF IsNull(is_memberid) OR sqlca.sqlcode <> 0 THEN is_memberid 	= ""
		
		//customerm Search
		select basecod, payid INTO :is_basecod, :is_payid  from customerm
		 where customerid =  :is_customerid ;
		
		IF IsNull(is_basecod)  OR sqlca.sqlcode <> 0 THEN is_basecod 	= ""
		IF IsNull(is_regcod)   OR sqlca.sqlcode <> 0 THEN is_regcod 	= ""
		
		//1.receiptMST Insert
		//SEQ 
		Select seq_receipt.nextval		  Into :is_appseq						  From dual;
		//SHOP COUNT
		Select shopcount	    Into :il_shopcount	  From partnermst
		 WHERE partner = :is_partner ;
		
		IF IsNull(il_shopcount) THEN il_shopcount = 0
		If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update Error(PARTNERMST)")
				Return 
		End If			
		
		il_shopcount += 1

			insert into RECEIPTMST
				( approvalno,	shopcount,		receipttype,	shopid,			posno,
				  workdt,		trdt,				memberid,		operator,		total,
				  cash,			change )
			values 
			   ( :is_appseq, 	:il_shopcount,	'100', 			 :is_partner, 	NULL,
				  :idt_saledt,	:idt_saledt,	 :is_customerid,:is_operator,	:idec_total,
				  :idec_cash,	:idec_change )	 ;
				   
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Insert Error(RECEIPTMST)")
				Return 
			End If			
		
		//ShopCount ADD 1
		Update partnermst
			Set shopcount 	= :il_shopcount
			Where partner  = :is_partner ;
		//Update 실패 
		If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update  Error(PARTNERMST)")
				Return 
		End If			

//-----------------------------------------------------------
//-----------------------------------------------------------
		// ADMST Update & dailypament에 Insert
		il_row 		= idw_data[2].RowCount()
		ii_method	= 1

		For i = 1 To il_row
			is_contno 		= trim(idw_data[2].object.contno[i])
			ls_restore 		= trim(idw_data[2].object.restore[i])
			idec_saleamt 	= idw_data[2].object.sale_amt[i]
			li_first 		= 0
			//a. ADMST Update
			IF ls_restore = '1' THEN
				//E1, A102
				idec_saleamt = idec_saleamt * -1
				Update ADMST
					Set saledt 		= :idt_saledt,
  					    customerid = :is_customerid,
  					    sale_amt 	= :idec_saleamt,
  					    Status 		= 'RT100',
						 updt_user 	= :gs_user_id,
						 updtdt 		= sysdate,
						 pgm_id 		= :is_pgm_id					 
					Where contno 	= :is_contno ;
			ELSE
				//E1 A103
				Update ADMST
					Set saledt 		= :idt_saledt,
  					    customerid = :is_customerid,
  					    sale_amt 	= :idec_saleamt,
  					    Status 		= 'SG100',
						 updt_user 	= :gs_user_id,
						 updtdt 		= sysdate,
						 pgm_id 		= :is_pgm_id					 
					Where contno 	= :is_contno ;
			END IF
				
			//저장 실패 
			If SQLCA.SQLCode < 0 Then
				RollBack;
				ii_rc = -1			
				f_msg_sql_err(is_title, is_caller + " Update Error(ADMST)")
				Return 
			End If	
			
			//b. dailypayment Insert
			// regcod search
			is_itemcod =  trim(idw_data[2].object.itemcod[i])
			select regcod INTO :is_regcod FROM ITEMMST
			 WHERE itemcod = :is_itemcod ;
			
			IF sqlca.sqlcode <> 0 OR IsNUll(is_regcod) then is_regcod = ""

			idec_saleamt =  idw_data[2].object.sale_amt[i]
			//반품시의 처리
			IF ls_restore = '1' THEN
				
			ELSE
			//-------------------------------------------------------------------------
			//입금내역 처리  Start........ 
			//-------------------------------------------------------------------------
			FOR li_pp =  ii_method to ii_amt_su
				is_method 	= is_paymethod[li_pp]
				idc_rem 		= idc_amt[li_pp]
	
				IF idc_rem >= idec_saleamt THEN
					ldc_saleamt =  idec_saleamt
					IF li_first =  0 then
						ii_paycnt 	= 1
						li_first 	= 1
					else 
						ii_paycnt 	= 0
					END IF
					idc_rem 			=  idc_rem -  ldc_saleamt
					idec_saleamt = 0
				ELSE
					ldc_saleamt 	= idc_rem
					ldc_salerem 	= idec_saleamt - idc_rem
					IF li_first =  0 then
						ii_paycnt 	= 1
						li_first 	= 1
					else
						ii_paycnt 	= 0
					END IF
					idec_saleamt = ldc_salerem 
					ii_method	+= 1
				END IF
				
				Select seq_dailypayment.nextval		  Into :il_payseq  From dual;
				IF sqlca.sqlcode < 0 THEN
						RollBack;
						ii_rc = -1			
						f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(seq_dailypayment)")
						Return 
				END IF

				insert into dailypayment
				( payseq,		paydt,			shopid,			operator,		customerid,
				  itemcod,		paymethod,		regcod,			payamt,			basecod,
				  paycnt,		payid,			remark,			trdt,				mark,
				  auto_chk,		dctype,			approvalno,		crtdt,			updtdt,		updt_user)
				values 
			   ( :il_payseq, 	:idt_saledt, 	:is_partner, 	:is_operator, 	:is_customerid,
				  :is_itemcod,	:is_method,		:is_regcod,		:ldc_saleamt,	:is_basecod,
				  :ii_paycnt,	:is_payid,		NULL,				:idt_saledt,	NULL,
				  NULL,			'D',				:is_appseq,		sysdate,			sysdate,		:gs_user_id )	 ;
				   
				//저장 실패 
				If SQLCA.SQLCode < 0 Then
					RollBack;
					ii_rc = -1			
					f_msg_sql_err(is_title, is_caller + " " + SQLCA.SQLErrText+ " Insert Error(DAILYPAMENT)")
					Return 
				End If		
	
				IF idec_saleamt = 0 then exit
			next
			END IF
			//--------------------------------------------
			// 입금처리 END.....
			//--------------------------------------------
			IF idc_rem > 0 then
				idc_amt[ii_method] = idc_rem
			END IF
		Next
End Choose
ii_rc = 0

//마지막으로 영수증 출력........
String ls_lin1, ls_lin2, ls_lin3
String ls_empnm
DEC	 ldc_shopCount

ls_lin1 = '------------------------------------------'
ls_lin2 = '=========================================='
ls_lin3 = '******************************************'

// Staff Name
select trim(EMPNM)   into :ls_empnm  from sysusr1t 
 where emp_id =  :gs_user_id ;
IF IsNull(ls_empnm) or sqlca.sqlcode <> 0  then ls_empnm = ''

//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//1. head 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
FOR jj = 1  to 2
	IF jj = 1 then 
		ldc_shopCount = f_pos_header(is_partner, 'A', il_shopcount, 1 )
	ELSE 
		ldc_shopCount = f_pos_header(is_partner, 'Z', il_shopcount, 0 )
	END IF
	IF ldc_shopCount < 0 then
		MessageBox('확인', '영수증 출력기에 문제 발생. 확인 바랍니다.')
		PRN_ClosePort()
		ii_rc = -9		
		return 
	END IF
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//2. Item List 출력
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	il_row = idw_data[2].RowCount()
	For i = 1 To il_row
		ls_temp 		= String(i, '000') + '  ' //순번
	
		is_itemcod 		= trim(idw_data[2].Object.itemcod[i])
		idec_saleamt	= idw_data[2].Object.sale_amt[i]	

		select itemnm INTO :is_itemnm FROM itemmst
		 WHERE itemcod = :is_itemcod ;
		IF sqlca.sqlcode <> 0 OR IsNull(is_itemnm) then is_itemnm = "" 

		ls_temp 	+= LeftA(is_itemnm + space(25), 25)  //아이템
		ls_temp 	+= Space(2) + '1' + space(2)   	  //수량
		is_val 	= fs_convert_amt(idec_saleamt,  7)
		ls_temp 	+= is_val //금액
		f_printpos(ls_temp)	
	
		is_regcod =  trim(idw_data[2].Object.regcod[i])
		//regcode master read
		select keynum, 		trim(facnum)
		  INTO :il_keynum,	:is_facnum
		  FROM regcodmst
		 where regcod = :is_regcod ;
	
		IF IsNull(il_keynum) 	then il_keynum 	= 0
		IF IsNull(is_facnum) 	then is_facnum 	= ""
		ls_temp =  Space(7) + "("+ is_facnum + '-KEY#' + String(il_keynum) + ")"
		f_printpos(ls_temp)
	NEXT
	f_printpos(ls_lin1)
//	ls_val 	= fs_convert_amt(ldec_total, 7)
	is_val 	= fs_convert_sign(idec_total, 7)
	ls_temp 	= LeftA("Grand Total" + space(35), 35) + is_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)
	//결제수단별 입금액
   For i = 1 To ii_amt_su
		is_val 	= fs_convert_sign(idc_amt[i],  7)
		ls_temp 	= LeftA(is_paymethod[i] + space(35), 35) + is_val
		f_printpos(ls_temp)
	NEXT
	//거스름돈 처리
	is_val 	= fs_convert_sign(idec_change,  7)
	ls_temp 	= LeftA("Changed" + space(35), 35) + is_val
	f_printpos(ls_temp)
	f_printpos(ls_lin1)

	ls_temp  = "Member ID   :     " + is_memberid	
	f_printpos(ls_temp)
	ls_temp  = "Approval No :     " + is_appseq	
	f_printpos(ls_temp)
	ls_temp  = "Staff Name  :     " + ls_empnm
	f_printpos(ls_temp)
	//--------------------------------------------
	PRN_LF(1)
	f_printpos_center("www.ssrt.com")
	f_printpos_center("Thank you for using SSRT service")

	PRN_LF(4)
	PRN_CUT()

next 
PRN_ClosePort()
ii_rc = 0
commit ;
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//   출력 완료	
//-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
Return 
end subroutine

on b1u_dbmgr1_ssrt_v20.create
call super::create
end on

on b1u_dbmgr1_ssrt_v20.destroy
call super::destroy
end on

event constructor;call super::constructor;////
end event

