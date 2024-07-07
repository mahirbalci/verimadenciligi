

#Kargo Analizi
#---Teslimat Süreleri Analizi
#---Maliyet Analizi
#---Müşteri Memnuniyeti Analizi


#Şikayet Var Kargo Yourmlarının Çekilmesi


library(rvest)
library(dplyr) 

url <- "https://www.sikayetvar.com/aras-kargo" #Şikayetlerin bulunduğu ana sayfanın URL'si.
pages <- 1:20 #Çekilmek istenen sayfa numaralarının bir listesi (1'den 20'ye kadar).

baslik <- list() #Şikayet başlıklarını saklamak için boş bir liste.

#Web sayfasına hangi tarayıcıdan bağlanıldığını belirtir 
#(bu, bazen sitelerin bot engelleme sistemlerini aşmak için kullanılır).

user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 
(KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"



# Her sayfa numarası için döngü başlatılır.
for (i in pages) {
  page_url <- paste0(url, "?page=", i) #Ana URL'ye sayfa numarasını ekleyerek tam sayfa URL'si oluşturulur.
  page <- read_html(page_url, user_agent = user_agent) #Belirtilen URL'deki HTML içeriği çekilir.
  
  baslik[[i]] <- page %>% #Çekilen HTML içeriğinden şikayet başlıkları seçilir ve metin olarak listeye eklenir.
    html_nodes(".complaint-title") %>%
    html_text()
}

#Veriyi Bir Veri Çerçevesine Dönüştürmek
yorum <- data.frame( #Tek boyutlu listeyi bir veri çerçevesine dönüştürür, "Baslik" adında bir sütun oluşturur.
  Baslik = unlist(baslik) #Listeyi düzleştirir (tek boyutlu hale getirir).
)


# dosya kaydetme 
write.xlsx(yorum,"C:/Users/DELL/Desktop/sosyal medya web proje/aras.xlsx" )  


library(rvest) #rvest, statik web sitelerini kazımanıza izin veren  R kütüphanesidir.
library(dplyr) #veri işleme ve dönüştürme işlemlerini kolaylaştırmak için geliştirilmiş bir pakettir. 
library(magrittr) #Fonksiyonlari %>% operatoru ile birbirine baglar.
library(purrr) #İslevler ve vektorlerle calismak icin eksiksiz ve tutarli bir arac seti saglayan paket.
library(dplyr) #Veri manipülasyon islemini yapar.
library(tidyverse) # veri setlerini düzenli, anlasilir ve etkili bir sekilde islemeyi sağlayan pakettir.
library(httpuv) #HTTP ve webSocket isteklerini islemek icin düsük seviyeli soket ve protokol destegi saglayan paket.
library(readr) # verileri okumayi kolaylastirir.
library(readxl) #Excel dosyalarini okur ve R'a yukleme yapar.
library(stringi) #Hizli ve tasinabilir karakter dizisi isleme tesisleri paketi.
library(stringr) #Karakter yapili veriler icin kullanilan paket.
library(tm) #Metin madenciliginde kullanilan paket.
library(pander) # tablolari ve cerceveleri goruntulemek icin tasarlanmistir.
library(wordcloud) #Kelime bulutu icin kullanilan pakettir.
library(ggplot2) #Verileri gorsellestirmek icin kullanilan paket.
library(tidytext) #Düzenli veri ilkelerini kullanmak ve bircok metin madenciligi gorevini yerine getirmek icin kullanilir.
library(RColorBrewer) #Kelime bulutunun renklendirilmesi icin kullanilir.
library(ggthemes) #grafiklerinizi daha cekici ve profesyonel gorunumlu hale getirmenize yardimci olur.
library(ggpubr) #ggplot2 ile birlikte kullanilir.
library(GGally) #cesitli grafik araclarini bir araya getiren bir pakettir. 
library(skimr) #veri cercevelerini ve veri setlerini ozetlemek ve kesfetmek icin kullanilan bir pakettir.
library(janitor) #veri setlerini temizlemeye yarar.
library(writexl) #Elde edilen verilerin excel formatinda disa aktarilmasi icin kullanilan pakettir.
library(stopwords) #Veri dosyasindan atilacak kelimeleri cikarmaya yarar. 
library(ggstance) #grafikler olusturmaya yarar.
library(ggeasy)

#dosyamızı çağırıyoruz
aras<- read_xlsx(file.choose())

#NA değer var mı diye baktık
anyNA(aras)

#url temizleme
aras$text<- str_replace_all(aras$text,"http[^[:space:]]*", "")

# hastag işareti ve @ işaretinin kaldırılması
aras$text<- str_replace_all(aras$text,"#//S+"," ")
aras$text<- str_replace_all(aras$text,"@//S+"," ")

# noktalama işaretlerinin temizlenmesi
aras$text<- str_replace_all(aras$text,"[[:punct:][:blank:]]+"," ")

#tüm harflerin küçük harfe dönüştürülmesi
aras$text<- str_to_lower(aras$text,"tr")
#rakamların temizlenmesi
aras$text<- removeNumbers(aras$text)

#ASCII formatına uymayan karakterlerin temizlenmesi
aras$text<- str_replace_all(aras$text,"[<].*[>]"," ")
aras$text<- gsub("\uFFD","",aras$text,fixed=TRUE)
aras$text<-gsub("\n","",aras$text,fixed = TRUE)

#Alfabetik olmayan karakterlerin temizlenmesi
aras$text<- str_replace_all(aras$text,"[^[:alnum:]]"," ")
Sys.setlocale("LC_CTYPE", "en_US.UTF-8")

#yazdırılan değerlerin max printini yükselttik
options(max.print = 999999)

#stopwords::stopwords("tr",source="stopwords-iso")

#Gereksiz verilerin listesi ve veri setinden cikartilmasi
#iso türkçe paketi kullanılmıştır oradaki kelimeler aşağıya eklenmiştir
liste <- c(stopwords("en"), "kargo", "acaba", "acep", "açıkça","ankara","izmir","daki","deki","nda", "nun","teslimat","teslimatı","kargoyu","ev","evde","eve","şubesi","şb","şube","edildi",
           "açıkçası", "adamakıllı", "adeta", "ait", "altı", "altmış", "gel","dan","aynı","tel","akü","edin",
           "ama", "amma", "anca", "ancak", "arada", "artık", "aslında", "aynen", "ayrıca", "kaldı","çorum","paketi","aktarma","firma","gitti",
           "az", "bana", "bari", "başka", "başkası", "bazen", "bazı", "belki", "ben", 
           "benden", "beni", "benim", "beri", "beriki", "beş", "bilcümle", "bile", "bin",
           "binaen", "binaenaleyh", "bir", "biraz", "birazdan", "birbiri", "birçoğu", "birçok",
           "birden", "birdenbire", "biri", "birice", "birileri", "birisi", "birkaç", "birkaçı", "vererek",
           "birkez", "birlikte", "birşey", "birşeyi", "bitevi", "sözde","bilecik","halde","istiyorum","evden","nin","gerçeği","iznim","kapısına","sağlam","deyip","ordu",
           "biteviye", "bittabi", "biz", "hala","haftadır","gündür","kargonun","haftadır",
           "bizatihi", "bizce", "bizcileyin", "bizden", "bize", "bizi", "bizim", "bizimki", 
           "bizzat", "boşuna", "böyle", "böylece", "böylecene", "böylelikle", "böylemesine",
           "böylesine", "bu", "buna", "bunda", "bundan", "bunlar", "bunları", "bunların", 
           "bunu", "bunun", "buracıkta", "burada", "buradan", "burası", "büsbütün", "bütün",
           "çabuk", "çabukça", "çeşitli", "çoğu", "çoğun", "çoğunca", "çoğunlukla", "çok", 
           "çokça", "çokları", "çoklarınca", "çokluk", "çoklukla", "cuk", "cümlesi", "çünkü",
           "da", "daha", "dahi", "dahil", "dahilen", "daima", "dair", "dayanarak", "de", "defa",
           "değil", "değin", "dek", "demin", "demincek", "deminden", "denli", "derakap", 
           "derhal", "derken", "diğer", "diğeri", "diye", "doğru", "doksan", "dokuz", "dolayı",
           "dolayısıyla", "dört", "edecek", "eden", "eder", "ederek", "edilecek", "ediliyor",
           "edilmesi", "ediyor", "eğer", "elbet", "elbette", "elli", "emme", "en", "enikonu",
           "epey", "epeyce", "epeyi", "esasen", "esnasında", "etmesi", "etraflı", "etraflıca",
           "etti", "ettiği", "ettiğini", "evleviyetle", "evvel", "evvela", "evvelce", 
           "evvelden", "evvelemirde", "evveli", "fakat", "filanca", "gah", "gayet", "gayetle",
           "gayri", "gayrı", "geçende", "geçenlerde", "gelgelelim", "gene", "gerçi", "gerek",
           "gibi", "gibilerden", "gibisinden", "gine", "gırla", "göre", "hakeza", "halbuki",
           "halen", "halihazırda", "haliyle", "handiyse", "hangi", "hangisi", "hani", "hariç",
           "hasebiyle", "hasılı", "hatta", "hele", "hem", "henüz", "hep", "hepsi", "her",
           "herhangi", "herkes", "herkesin", "hiç", "hiçbir", "hiçbiri", "hoş", "hulasaten", 
           "için", "iken", "iki", "ila", "ile","lı","yı", "gün","ilen", "ilgili", "ilk", "illa", "içi","çin","nolu","noldu","yol","yola","zil","bulunuyor","kdm","isini","işini","kaç","bursa","diyor","ücret","dışı",
           "illaki", "imdi", "indinde", "inen", "insermi", "iş", "ise", "işte", 
           "ister", "itibaren", "itibariyle", "itibarıyla", "iyi", "iyice", "iyicene",
           "kaçı", "kadar", "kaffesi", "kah", "kala", "kanımca", "karşın", "katrilyon",
           "kaynak", "kelli", "kendi", "kendilerine", "kendini", "kendisi", "kendisine", 
           "kendisini", "kere", "keşke", "kez", "keza", "kezalik", "ki","adrese",
           "kim", "kimden", "uzun","yere","paket","allah","servis","ekibi","türlü","gelip","aydır","verdi","hakkı","ürünün","edemiyor","aldı",
           "kime", "kimi", "kimisi", "kimse", "kimsecik", "kimsecikler", "kırk", "kısaca", 
           "külliyen", "lakin", "leh", "lütfen", "maada", "madem", "mademki", "mamafih", "mebni", "meğer", "meğerki", "meğerse", "milyar", 
           "milyon", "mı", "mu", "mü","dağıtıma", "naşi", "nasıl", "nasılsa", "nazaran", "ne", "neden", 
           "nedeniyle", "nedenle", "nedense", "nerde", "nerden", "nerdeyse", "nere", "nerede", 
           "nereden", "neredeyse", "neresi", "nereye", "netekim", "neye", "neyi", "neyse", "nice", 
           "niçin", "nihayet", "nihayetinde", "nitekim", "niye", "o", "öbür", "öbürkü", "öbürü", "olan",
           "olarak", "oldu", "olduğu", "olduğunu", "oldukça", "olduklarını", "olmadı", "olmadığı", "olmak", "olması", "olmayan", "olmaz", "olsa", "olsun", "olup", "olur", "olursa", "oluyor", 
           "on", "ona", "onca", "önce", "önceden","müşteri","kargom", "önceleri", "öncelikle", "onculayın", "onda", 
           "ondan", "onlar", "onlardan", "onları","kargomu", "onların", "onu", "onun", "oracık", "oracıkta", 
           "orada", "oradan", "oranca", "oranla", "oraya", "öteki", "ötekisi", "otuz", "öyle", "öylece", 
           "öylelikle", "öylemesine", "oysa", "oysaki", "öz", "pek", "pekala", "pekçe", "peki", "peyderpey", "rağmen", "sadece", "sahi", 
           "sahiden", "sana", "sanki", "şayet", "sekiz", "seksen", "sen", "senden", "seni", "senin", "şey", "şeyden", "şeyi", "şeyler", "şimdi", "siz", "sizden", "sizi", "sizin", "sonra", "sonradan", "sonraları", "sonunda", "şöyle", "şu", "şuna", "şuncacık", "şunda", "şundan", "şunlar", "şunları", "şunu", "şunun", "şura", "şuracık", "şuracıkta", "şurası", "tabii", "tam", "tamam", "tamamen", "tamamıyla", "tarafından", "tek", "trilyon", "tüm", "üç", "üzere", "var", "vardı", "vasıtasıyla", "ve", "velev", "velhasıl", "velhasılıkelam", "veya", "veyahut", "ya", "yahut", "yakinen", "yakında", "yakından", "yakınlarda", "yalnız", "yalnızca", "yani", "yapacak", "yapılan", "yapılması", "yapıyor", "yapmak", "yaptı", "yaptığı", "yaptığını", "yaptıkları", "yedi", "yeniden", "yenilerde", "yerine", "yetmiş", "yine", "yirmi", "yok", "yoksa", "yoluyla", "yüz", "yüzünden", "zarfında", "zaten", "zati", "zira")

aras$text <- removeWords(aras$text, liste)


kelimeler<- aras%>% mutate(linenumber=row_number()) %>% unnest_tokens(word,text)

kelimeler %>%
  count(word,sort=TRUE) %>% #sort true demek büyükten küçüğe sıralamak
  filter(n > 15) %>% # N değeri 15ten yüksek tekrar edenleri alıyoruz
  mutate(word=reorder(word,n))%>%
  filter(!is.na(word)) %>% #na değerleri filtreledik
  filter(n>0) %>% #frekansı 0 olanları filtreledik
  ggplot(aes(word,n))+ geom_col()+ xlab(NULL)+ coord_flip()+theme_minimal() +ggtitle("Yorum verisindeki kelimelerin frekans analizi")

wordcloud(kelimeler$word,min.freq = 1,colors = brewer.pal(6,"Dark2"),random.color = T,random.order = F)


kutuphane <- aras

#Turkce kelimelerin polarite karsiligi -1 ve 1 olan lexicon verisetini cagirma

lexicon <- read.table(file.choose(),
                      header = TRUE,
                      sep = ';',
                      quote = "",
                      stringsAsFactors = FALSE)



#lexicon verisetindeki WORD ve POLARITY sutunlarını alip
#word ve value olarak lexicon2 veriseti olusturur




lexicon2 <- lexicon %>%
  select(c("ï..WORD","POLARITY")) %>%
  rename('word'="ï..WORD", 'value'="POLARITY")



kutuphane %>%
  mutate(linenumber = row_number()) %>% #her satira bir numara ekler
  unnest_tokens(word, text) %>% #metinleri kelimelere ayirir
  inner_join(lexicon2) %>% #bu kelimeleri lexicon ile eslestirir
  group_by(linenumber) %>% #her satir icin duygu degerlerini toplar ve linenumber ile gruplandirir
  summarise(sentiment = sum(value)) %>% #sonuclari dosyaya yazdirir
  left_join(
    kutuphane %>%
      mutate(linenumber = row_number())
  ) %>% write_csv("sentiment_output.csv")

#sonuclari analiz etme ve gorsellestirme
yeni <- read_csv("sentiment_output.csv")

#duygu analizi sonuclarini degerlendirme
neutral <- length(which(yeni$sentiment == 0))
positive <- length(which(yeni$sentiment > 0))
negative <- length(which(yeni$sentiment < 0))

#toplam duygu sayisini hesaplama
toplam = positive + neutral + negative

#duygu kategorileri ve oranlari icin veri cercevesi olusturma
Sentiment <- c("Pozitif", "Nötr", "Negatif")
Count <- c((positive/toplam)*100, (neutral/toplam)*100, (negative/toplam)*100)
output <- data.frame(Sentiment, Count)

#duygu kategorilerini factore donusturme
output$Sentiment <- factor(output$Sentiment, levels=Sentiment)

#bar plot ile duygu analizi oranlarini gorsellestirme
ggplot(output, aes(x=Sentiment, y=Count))+
  geom_bar(stat = "identity", aes(fill = Sentiment))+
  ggtitle("Yorumların Duygu Analizinin Oranları")

#oranlarin head degerleri
head((positive/toplam)*100)
head((neutral/toplam)*100)
head((negative/toplam)*100)









