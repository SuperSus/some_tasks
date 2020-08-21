# Test Task

### 1. Если 20% от a равно 30% от b, то a:b равно?

<dl>
  <dt>a*0.2 = b*0.3</dt>
  <dt>a/b = 0.3/0.2</dt>
  <dt><b>answer:</b> a:b = 1.5</dt>
</dl>

### 2. Используя данные ​таблицы...

[Result Table](https://docs.google.com/spreadsheets/d/1Kt-dAZWx_z7hE7JxczdTby7DarM1smy3aEfy-MQQ8LQ/edit?usp=sharing)

<dl>
  <dt>Докинул колонку к исходной табличке PriceInt т.к Price в текстовом типе</dt>
  <dt>Решил сделать pivot table на основе полученной таблички</dt>
  <dt>Сгруппировал табличку по <b>ResortName</b> и <b>Travel Method</b></dt>
  <dt>Добавил фильтр для <b>Travel Method</b>, <b>Travel Method</b> == 'Train' OR  <b>Travel Method</b> == 'Plane'<dt>
</dl>

### 4

awk '{ print \$1}' access.log | sort | uniq -c | sort -nr | head -n 10

### 5

Какие индексы оптимальнее создать для таблиц Table1 и Table2?

<dl>
  <ul>
    <li>значения полей ID1, ID2, ID3 равномерно распределены между 0 и 1000 - высокий <b>cardinality</b></li>
    <li> в обеих таблицах по миллиону записей - записей достататочно много</li>
    </br>
  </ul>
  в индексах есть смысл!
  </br>
  <dt>
    INNER JOIN Table2 T2 USING(ID1,ID3)
    </br>
    т.к скорее всего будет использована nested-loop join strategy нужны индексы ID2_ID3 в обеих табличках
    <ul>
      <li>alter table Table1 add key (ID1,ID3)</li>
      <li>alter table Table2 add key (ID1,ID3);</li>
    </ul>
  </dt>
  </br>
  <dt>
    WHERE T1.ID2 BETWEEN 600 AND 700
    </br>
    тут я бы добавил: alter table Table1 add key (ID2)
  </dt>
  </br>
  <dt>
     T1.ID1 & 3 = 0
    </br>
    индекс не нужен уже есть: alter table Table1 add key (ID1,ID3)
  </dt>
  </br>
  <dt>
    T2.ID3 BETWEEN 600 AND 700
    </br>
    alter table Table2 add key (ID3);
  </dt>
  </br>
  <dt>
    GROUP BY T1.ID3
    </br>
    если будет использоваться sort/group algorithm тогда нужен
    </br>
    alter table Table1 add key (ID3)
  </dt>
  </br>
</dl>
