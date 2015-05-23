#include "uthash.h"
#include <stdlib.h>

typedef struct variavel {
  int   tipo;
  int   pos;
} Variavel;

typedef struct entry {
  char           id[64]; // key
  Variavel      *var;
  UT_hash_handle hh;
} *HashTable;

//funçao para fazer get de uma variavel com um dado nome
Variavel* hash_get(HashTable hash, char *key) {
  struct entry *temp;

  HASH_FIND_STR(hash, key, temp);

  if (temp == NULL) return NULL;
  else return temp->var;
}

//funçao para colocar uma variável com um dado nome, tipo e valor???
void hash_put(HashTable hash, char *id, int tipo, int pos) {
  //printf("A introduzir a variável: %s, do tipo: %d, na posição: %d\n",id,tipo,pos);

  struct entry *temp = malloc(sizeof(struct entry)), *old,*temp2;
		Variavel *v = malloc(sizeof(struct variavel));
		v->tipo=tipo;
		v->pos=pos;

  strcpy(temp->id, id);
  temp->var = v;
  HASH_REPLACE_STR(hash, id, temp, old);

  if (old) free(old);
}

//funcao para retornar o número de variáveis
int hash_size(HashTable hash) {
  return HASH_COUNT(hash);
}

//funcao para limpar toda a tabela e remover a memória alocada
//de notar que os endereços retornados pelo método get
//irão agora apontar para NULL (ou undefined)
void hash_clear(HashTable *h) {
	struct entry *entry,*temp;
	HASH_ITER(hh,(*h),entry,temp){
		HASH_DEL((*h),entry);
		free(entry->var);
		free(entry);
	}
}

// teste exemplo, remover para integrar no projeto
/*int main() {
  //deve se inicializar a hashtable a null
  HashTable h = NULL;
  Variavel *v;
  hash_put(&h, "asd",  2,(void *)"ola");
		hash_put(&h, "asdd",  1,(void *)"ola");
  v = hash_get(h, "asd");
  printf("Tipo:%d ",    v->tipo);
  printf("Valor:%s \n", ((char *)(v->valor)));
  printf("%d \n",       hash_size(h));
		hash_clear(&h);
		printf("%d \n",       hash_size(h));
}*/
