# Goat Fable

**Claude Opus 4.8'i Fable 5 disipliniyle çalıştıran davranış paketi.** Guidelines, sistem promptları, Claude Code skill'leri, subagent'lar, bir doğrulama hook'u ve paketi kendi reponda test etmen için bir eval seti.

*English summary below: [What is this?](#english)*

---

## Dürüst çerçeve

Bir prompt paketi modele ham zeka ekleyemez. Ekleyebildiği şey davranıştır, ve agentic coding'de günlük performans farkının büyük kısmı davranıştan gelir: doğrulamadan "bitti" demek, semptomu yamalayıp kök nedeni bulmamak, dört maddelik işin üçüncüsünü sessizce düşürmek, testi zayıflatarak yeşile çekmek, zor bug'da aynı başarısız yaklaşımı üçüncü kez denemek. Bunların hepsi yazıya dökülebilir, ve Opus 4.8 talimat takibi çok güçlü bir model olduğu için yazılanı uygular.

Gerçekçi beklenti: rutin ve orta-zor mühendislik işlerinde Fable 5'e yakın davranış kalitesi. En zor kuyrukta (çok dosyalı ince invariant'lar, çok uzun ufuklu tutarlılık) ham muhakeme farkı durur; onu prompt kapatmaz. Bu paketi değerli yapan şey vaadin büyüklüğü değil, hedefin isabeti: neyin kapatılabilir olduğunu bilip sadece onu hedefler.

Neden Opus 4.8: Fable 5 en iyi model, ama quota ve maliyet gerçeği var. Günlük işlerin çoğunu Opus 4.8 + doğru davranış katmanıyla taşımak, Fable'ı gerçekten gerektiren işlere saklamak çoğu geliştirici için doğru ekonomi.

## Neyi hedefliyor: resmi gap haritası

Bu paket tahminle değil, Anthropic'in kendi dokümantasyonuyla hedef seçti. Fable 5'in Opus 4.8'e karşı resmi olarak daha iyi ilan edildiği alanlar, birebir bu paketin modülleri:

| Fable 5'in resmi avantajı | Paketteki karşılığı |
|---|---|
| Kendi işini doğrulama (self-verification) | Çekirdek §1 ve §6, `verify-done` skill, stop-verify hook |
| Uzun ufuklu tutarlılık | `guides/long-tasks.md`: durumu dosyaya yazma, tek-iş-tek-doğrulama |
| Bug bulma recall'u | `agents/code-reviewer.md`: iki geçişli (bul → çürüt) review |
| Subagent yönetimi | `guides/orchestration.md` + fresh-context `verifier` agent'ı |
| Belirsizlikte doğru kalibrasyon | Çekirdek §11: sor/varsay/devam et kuralları |
| Dürüst durum raporları | Çekirdek §1: kanıtsız iddia yasağı, iddia-kanıt eşlemesi |

Ayrıca Opus 4.8'in dokümante edilmiş kendine özgü davranışları (literal talimat takibi, az subagent açması, fazla izin sorması, review'da severity filtresinin recall düşürmesi) tek tek karşılanıyor: `guides/opus-4-8.md`.

## Mimari: neden üç katman

30k token'lık kural kitabını sürekli context'te tutmak talimat takibini *seyreltir*; uzun CLAUDE.md dosyalarının kurallarının yok sayılması bilinen bir başarısızlık modudur. Bu yüzden paket katmanlı:

- **Katman 0, her zaman yüklü**: `core/CLAUDE-CORE.md` (~200 satır). En yüksek kaldıraçlı 12 davranış. Her satır "sıklık × davranış değişimi × hata maliyeti" hesabıyla yerini hak ediyor.
- **Katman 1, tetiklenince**: dört skill. `plan-first` (karmaşık işe plansız girmeyi engeller), `deep-debug` (kök neden protokolü), `self-review` (diff kalite taraması), `verify-done` (kanıt kontrolü + dürüst rapor).
- **Katman 2, ihtiyaç anında okunur**: yedi derin rehber. Çekirdek, tetik koşulu gerçekleşince ilgili rehberi okumaya yönlendirir ("iki fix denemesi başarısızsa debugging.md'yi oku").
- **Artı iki güvence**: prompt katmanı tavsiyedir, `hooks/stop-verify.sh` deterministik kapıdır (değişiklik var + hiç test koşmadı + çıkmaya çalışıyor → bir kez durdurur). `agents/verifier.md` ise senin context'ine bulaşmamış taze gözle işi gereksinimlere karşı denetler; fresh-context doğrulayıcının self-critique'ten iyi olması resmi tavsiyedir.

## Repo haritası

| Dizin | İçerik |
|---|---|
| `core/` | Katman 0 çekirdek: her zaman yüklü 12 davranış |
| `guides/` | 7 derin rehber: debugging, verification, code-quality, communication, long-tasks, orchestration, opus-4-8 |
| `skills/` | 4 Claude Code skill'i (otomatik tetiklenir, `/isim` ile de çağrılır) |
| `agents/` | verifier + code-reviewer subagent tanımları |
| `hooks/` | stop-verify hook + önerilen settings |
| `api/` | Claude Code dışı kullanım: tam ve kompakt sistem promptları + 4 task template (bugfix, feature, refactor, review) |
| `eval/` | Paketi KENDİ reponda A/B test etme kiti: 8 davranış tuzağı görev, rubrik, judge promptu |

## Hızlı kurulum

```bash
git clone https://github.com/goatstarter/goat-fable.git
cd goat-fable
./install.sh /path/to/projen
```

Sonra projede bir session açıp:

```
/model claude-opus-4-8
/effort xhigh
```

`xhigh`, Anthropic'in Opus 4.8'de agentic coding için önerdiği başlangıç seviyesi. Detaylar, manuel kurulum, API kullanımı ve doğrulama adımları: `INSTALL.md`.

## Nasıl üretildi

Üç kaynağın distilasyonu:

1. **Fable 5'in kendi çalışma disiplini.** Bu paketin içeriği Fable 5 tarafından yazıldı: modelin fiilen uyguladığı karar kuralları (kanıt standardı, bitirme protokolü, sor/devam et kalibrasyonu) Opus 4.8'in uygulayabileceği açık talimatlara döküldü.
2. **Anthropic'in resmi dokümantasyonu**: Opus 4.8 prompting rehberi ve quirk listesi, Fable 5 prompting rehberi (gap haritası), Claude Code best practices, uzun görev harness rehberi. Kaynak linkleri `guides/opus-4-8.md` sonunda.
3. **Dokümante edilmiş başarısızlık modları**: reward hacking araştırması (görünür testi geçip gizli testi geçememe), premature completion, fabricated status reports. Eval setindeki 8 tuzak doğrudan bunlardan türetildi.

## Ne beklemelisin, ne beklememelisin

- Paket kural kitabı değil, kalibre edilmiş bir çekirdek + ihtiyaç anında derinlik. Kendi kurallarını eklerken aynı disipline uy: tetik koşulu olmayan, pozitif ifade edilmemiş, ölçülemeyen kural ekleme.
- Etkiyi vibes'la değil ölçerek değerlendir: `eval/` bunun için var. Kendi reponda 8 görevi iki kolda (paketli/paketsiz) koştur, rubrikle puanla. Bir boyut senin reponda kıpırdamıyorsa o kurallar senin için ölü ağırlıktır: buda.
- Paket Opus 4.8'e kalibre edildi ama çekirdek disiplin model-bağımsızdır: Sonnet'te de işe yarar, Fable 5'te zararsız ama gereksizdir (o davranışlar zaten native).

---

<a name="english"></a>
## English

**Goat Fable is a behavior pack that runs Claude Opus 4.8 with Fable 5's working discipline**: an always-loaded ~200-line operating core, four auto-triggering Claude Code skills (plan-first, deep-debug, self-review, verify-done), on-demand deep guides, a fresh-context verifier subagent, a deterministic stop-verify hook, standalone API system prompts with task templates, and an eval kit (8 behavior-trap tasks + rubric + judge prompt) to A/B the pack on your own repo.

A prompt pack can't add raw intelligence; it can close the *behavioral* gap, which is most of the day-to-day difference: unverified "done" claims, symptom-patching, silently dropped requirements, test-gaming, scope creep. The targets come straight from Anthropic's own docs: the officially stated Fable 5 advantages over Opus 4.8 (self-verification, long-horizon coherence, bug-finding recall, delegation, calibrated ambiguity handling, grounded progress claims) map one-to-one onto this pack's modules, and Opus 4.8's documented quirks each get their official countermeasure (`guides/opus-4-8.md`).

```bash
git clone https://github.com/goatstarter/goat-fable.git && cd goat-fable
./install.sh /path/to/your/project
# then, in a session: /model claude-opus-4-8  and  /effort xhigh
```

Full instructions in `INSTALL.md`, API usage in `api/README.md`. Honest expectations: near-Fable behavior on routine-to-moderately-hard engineering work; the raw-reasoning gap on the hardest tail remains. Measure it on your repo with `eval/` instead of trusting vibes (including ours).

## Lisans / License

MIT. Goatstarter topluluğu için hazırlandı; issue ve PR açık.
