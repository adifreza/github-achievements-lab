# Panduan GitHub Achievements (gh CLI + git)

> Semua di repo **publik**. Achievement dari repo privat sering tidak dihitung.
> Pastikan Settings profil > "Show Achievements" aktif.
> Achievement muncul beberapa menit s/d ~24 jam setelah syarat terpenuhi.

Ganti `OWNER` dengan username GitHub kamu di semua perintah.

---

## 0. Setup repo

```bash
# prasyarat
gh auth status                 # harus sudah login
gh auth login                  # kalau belum

cd github-achievements-lab
git init -b main
git add .
git commit -m "chore: init achievements lab"

# buat repo publik di GitHub + push
gh repo create github-achievements-lab --public --source=. --remote=origin --push
```

Verifikasi:

```bash
gh repo view --web
```

---

## 1. Quickdraw — tutup issue < 5 menit

```bash
# buat issue, catat nomornya (mis. #1)
gh issue create --title "quickdraw test" --body "akan ditutup cepat"

# langsung tutup (dalam 5 menit)
gh issue close 1
```

Selesai. (Menutup PR dalam < 5 menit juga sah, tapi issue paling gampang.)

---

## 2. YOLO — merge PR tanpa review

```bash
git checkout main && git pull --ff-only
git checkout -b feat/yolo
echo "- yolo $(date -u +%FT%TZ)" >> docs/log.md
git add docs/log.md
git commit -m "feat: yolo change"
git push -u origin feat/yolo

gh pr create --base main --head feat/yolo --title "YOLO" --body "merge tanpa review"
gh pr merge feat/yolo --squash --delete-branch
```

Karena repo baru tidak punya branch protection, merge tanpa review = YOLO.

---

## 3. Pull Shark — merge banyak PR kecil

Tier: **2** (default badge), 16, 128, 1024. Self-merge dihitung.

Otomatis:

```bash
bash scripts/pull-shark.sh 3      # bikin + merge 3 PR
```

Manual (ulangi sesukanya, ganti nama branch tiap kali):

```bash
git checkout main && git pull --ff-only
git checkout -b chore/tweak-1
echo "- tweak 1" >> docs/log.md
git add docs/log.md && git commit -m "docs: tweak 1"
git push -u origin chore/tweak-1
gh pr create --base main --head chore/tweak-1 --title "docs: tweak 1" --body "kecil"
gh pr merge chore/tweak-1 --squash --delete-branch
```

---

## 4. Pair Extraordinaire — commit co-authored, PR ter-merge

Butuh **akun GitHub kedua** (atau teman). Commit harus punya trailer
`Co-authored-by:` dengan email yang terhubung ke akun itu, dan PR-nya di-merge.

### 4a. Cari email no-reply akun kedua

```bash
# ambil user id akun kedua
gh api users/AKUN_KEDUA --jq .id
```

Formatnya: `ID+AKUN_KEDUA@users.noreply.github.com`
(mis. `12345678+teman@users.noreply.github.com`).
Kalau akun kedua tidak menyembunyikan email, boleh pakai email verified-nya langsung.

### 4b. Buat commit + PR

```bash
git checkout main && git pull --ff-only
git checkout -b feat/pair
echo "- pair work $(date -u +%FT%TZ)" >> docs/log.md
git add docs/log.md

git commit -m "feat: pair-programmed change

Co-authored-by: AKUN_KEDUA <ID+AKUN_KEDUA@users.noreply.github.com>"

git push -u origin feat/pair
gh pr create --base main --head feat/pair --title "Pair" --body "co-authored"

# pakai merge commit (bukan squash) supaya trailer pasti ikut
gh pr merge feat/pair --merge --delete-branch
```

Cek trailer sebelum push:

```bash
git log -1 --format='%B'      # harus ada baris "Co-authored-by:"
```

> Kedua akun (kamu + co-author) dapat achievement ini.

---

## 5. Galaxy Brain — jawaban di Discussion ditandai sebagai answer

Tier: **2**, 8, 16, 32. `gh` belum punya perintah discussion khusus, jadi pakai GraphQL via `gh api graphql`.

> Paling aman: **akun kedua yang bertanya**, kamu (pemilik repo) yang menjawab
> lalu menandai jawaban. Menjawab pertanyaan sendiri di repo sendiri
> secara historis juga jalan, tapi GitHub sudah memperketat anti-farming —
> kalau tidak unlock dalam 24 jam, pakai cara akun kedua.

### 5a. Aktifkan Discussions

```bash
gh repo edit OWNER/github-achievements-lab --enable-discussions
```

### 5b. Ambil repo id + id kategori Q&A

```bash
gh api graphql -f query='
{
  repository(owner:"OWNER", name:"github-achievements-lab") {
    id
    discussionCategories(first:20) { nodes { id name isAnswerable } }
  }
}'
```

Catat `repository.id` dan `id` dari kategori yang `isAnswerable: true` (biasanya "Q&A").

### 5c. Buat discussion (pertanyaan)

```bash
gh api graphql -f query='
mutation {
  createDiscussion(input:{
    repositoryId:"REPO_ID",
    categoryId:"QA_CATEGORY_ID",
    title:"Gimana cara kerja achievement Galaxy Brain?",
    body:"Nanya biar bisa dijawab untuk latihan."
  }) { discussion { id number url } }
}'
```

Catat `discussion.id`.

### 5d. Tambah jawaban (comment)

```bash
gh api graphql -f query='
mutation {
  addDiscussionComment(input:{
    discussionId:"DISCUSSION_ID",
    body:"Jawaban: tandai comment ini sebagai answer maka Galaxy Brain kebuka."
  }) { comment { id } }
}'
```

Catat `comment.id`.

### 5e. Tandai sebagai answer

```bash
gh api graphql -f query='
mutation {
  markDiscussionCommentAsAnswer(input:{ id:"COMMENT_ID" }) {
    discussion { id url }
  }
}'
```

Buka `discussion.url` untuk memastikan ada centang hijau "Answer".

---

## 6. Verifikasi achievement

```bash
gh api users/OWNER --jq '{login,name}'
```

Buka di browser:

- `https://github.com/OWNER?tab=achievements`
- atau tab **Overview** profil (bagian Achievements di sidebar kiri)

Kalau belum muncul:

1. Tunggu s/d 24 jam.
2. Pastikan repo **publik** dan aksi (PR/issue/discussion) benar-benar ke repo publik itu.
3. Settings > Public profile > centang **Show Achievements**.
4. Untuk Pull Shark/Pair: pastikan PR statusnya **Merged** (bukan Closed).
5. Untuk Pair: `git log` di branch commit harus menampilkan baris `Co-authored-by:` persis.
6. Untuk Galaxy Brain: comment harus punya badge **Answer** (hijau).
