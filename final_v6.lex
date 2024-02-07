

%{
//testing branch
//testing

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int section = 0;
typedef struct {
    char type[20];
    char value[256];
    int sec ;
    int tokenNo;
} Token;

Token token;

Token Identifier1[100];
Token Identifier2[100];
Token Identifier3[100];
int noIden1 = 0;
int noIden2 = 0;
int noIden3 = 0;

int compareStructs(const void *a, const void *b) {
    return strcmp((( Token*)a)->value, (( Token*)b)->value);
}

int errorFlag = 0;

%}





OP [-|+|*|/|=|(|)]
Word [_a-zA-Z][_a-zA-Z0-9]*
Int [0-9]+
Real [0-9]*\.?[0-9]+
Bracket [\{|\}|\[|\]]

%%

"\n" {
    printf("new line\n\n");
    errorFlag =0;
    return 2;
}


"Section1"  {
                if (section == 0) {
                    //printf("Found Section1");
                    section = 1;
                    return 1;
                } else {
                    //printf( "Error: Unexpected Section1\n");
                    strcpy(token.type, "ERROR");
                    section = 1;
                    //errorFlag= 1;
                    return -2;
                }
            }

"Section2"  {
                if (section == 1) {
                    //printf("Found Section2");
                    section = 2;
                    return 1;
                } else {
                    //printf("Error: Unexpected Section2\n");
                    strcpy(token.type, "ERROR");
                    section = 2;
                    //errorFlag= 1;
                    return -2;
                }
            }

"Section3"  {
                if (section == 2) {
                    //printf("Found Section3\n\n");
                    section = 3;
                    return 1;
                } else {
                    section = 3;
                    //printf("Error: Unexpected Section3\n");
                    strcpy(token.type, "ERROR");
                    //errorFlag= 1;
                    return -2;
                }
            }

{OP}        {
                //printf("operator : %s \n",yytext);
                strcpy(token.type, "Op");
                strcpy(token.value , yytext);
                return 0;
            }//Operators

[ ]         {
                //printf("Universal delimiter\n");
                strcpy(token.type, "Delimter");
                strcpy(token.value , yytext);
                return 0;
            }// Space

{Bracket}   {
                //printf("brackets\n");
                if(section == 2){
                    strcpy(token.type, "Brackets");
                    strcpy(token.value , yytext);
                    return 0;
                }
                else{
                    printf("Error ");
                    strcpy(token.type, "Minor Error");
                    strcpy(token.value , yytext);
                    //errorFlag = 1;
                    return -4;
                }
            }//Bracket

[\t]     {
                printf("tab Ignored\n");
                return 2;

            }//Tab or New Line

{Word}      {
                //printf("Identifier : %s \n",yytext);
                strcpy(token.type, "Identifier");
                strcpy(token.value , yytext);
                token.sec = section;
                int flag = 0;
                if(section>1){
                    for(int i = 0 ; i <noIden1;i++){
                        if(strcmp(Identifier1[i].value,token.value)==0 && Identifier1[i].sec==1){
                            flag = 1;
                            break;
                        }
                    }
                    if(flag ==0){
                        if(errorFlag==0){
                            return -5;
                        }
                        
                        //errorFlag= 1;
                    }
                }
                
                return 0;
            }//word

{Int}       { 
                //printf("Signed Integer: %s\n", yytext);
                strcpy(token.type, "Integer");
                strcpy(token.value , yytext);
                return 0; 
            }//Int

{Real}      { 
                //printf("Signed Real: %s\n", yytext); 
                strcpy(token.type, "Real");
                strcpy(token.value , yytext);
                return 0; 
            }//Real Numbers

<<EOF>>     {
                //printf(" --EOF Detected-- \n");
                return -3;
            }

. {
    //printf( "Error: Unexpected character '%s'.\n", yytext);
    //errorFlag= 1;
    return -1;
}
%%

int yywrap(){
}

//2 normal but no print eg tab, newline
//1 Section found
//0 normal 
//-1 Minor Error
//-2 Crititcal Error 
//-3 EOF
//-4 Brackets not in correct Section
//-5 Identifier not in section 1



int main(){
    while(1){
        int ret = yylex();

        if(errorFlag ==1){
            //printf("NOT stored going ahead till new line \n\n");
            continue;
        }
        if(ret == -5){
            printf("Error: identifier \" %s \" was not declared in section1 \n",token.value);
            errorFlag=1;
            continue;
        }
        if(ret == -4){
            printf("Error: Brackets not allowed in this section\n");
            errorFlag = 1;
            continue;
        }
        if(ret==-3){
            printf("--EOF-- \n");
            break;
        }
        if(ret == -2){
            printf("Error: Invalid Section %d \n",section);
            errorFlag = 1;
            break;
        }
        if(ret == -1){
            printf("Error: Minor Errror \n");
            errorFlag = 1;
            continue;
        }
        //if error flag continue
        

        if(ret == 0 ){
            printf("Val: %s , Type: %s  \n", token.value,token.type);
            
            if(strcmp(token.type,"Identifier")==0){
                if(token.sec==1){
                    Identifier1[noIden1] = token;
                    Identifier1[noIden1].tokenNo = noIden1;
                    noIden1++;
                }
                if(token.sec==2){
                    Identifier2[noIden2] = token;
                    Identifier2[noIden2].tokenNo = noIden2;
                    noIden2++;
                }
                if(token.sec==3){
                    Identifier3[noIden3] = token;
                    Identifier3[noIden3].tokenNo = noIden3;
                    noIden3++;
                }
            }
        }
        if(ret == 1){
            printf("Section %d found \n",section);
            continue;
        }
        if(ret == 2){
            continue;
        }
        
    }

    //code to sort the array of structs Identifier1 according to string value

    size_t arraySize = sizeof(Identifier1) / sizeof(Identifier1[0]);

    // Sort the array using qsort
    qsort(Identifier1, noIden1, sizeof( Token), compareStructs);
    qsort(Identifier2, noIden2, sizeof( Token), compareStructs);
    qsort(Identifier3, noIden3, sizeof( Token), compareStructs);



    for(int i= 0; i <noIden1;i++){
        printf("(%d) %s : Section = %d  , token pos: %d\n",i,Identifier1[i].value,Identifier1[i].sec, Identifier1[i].tokenNo );
    }
    for(int i= 0; i <noIden2;i++){
        printf("(%d) %s : Section = %d  , token pos: %d\n",i,Identifier2[i].value,Identifier2[i].sec,Identifier2[i].tokenNo);
    }
    for(int i= 0; i <noIden3;i++){
        printf("(%d) %s : Section = %d  , token pos: %d\n",i,Identifier3[i].value,Identifier3[i].sec,Identifier3[i].tokenNo);
    }
    return 0;
}