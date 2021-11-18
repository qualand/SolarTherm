typedef struct {  /* User-defined datastructure of the table */ 
  double* array;      /* nrow*ncolumn vector       */ 
  int     nrow;       /* number of rows            */ 
  int     ncol;       /* number of columns         */ 
  int     type;       /* interpolation type        */ 
  int     lastIndex;  /* last row index for search */ 
} MyTable; 

void* initMyTable(const  char* fileName,  const  char* tableName) { 
  MyTable* table = malloc(sizeof(MyTable)); 
  if ( table ==  NULL ) ModelicaError("Not enough memory"); 
  // read table from file and store all data in *table 
  return (void*) table;
}; 

void closeMyTable(void* object) { /* Release table storage */ 
  MyTable* table = (MyTable*) object; 
  if ( object == NULL )  return; 
  free(table->array); 
  free(table); 
} 

double interpolateMyTable(void* object, double u) { 
  MyTable* table = (MyTable*) object; 
  double y; 
  // Interpolate using "table" data (compute y) 
  return y; 
}; 