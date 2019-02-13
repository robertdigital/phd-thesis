RMD := $(shell find . -type f -name '*.Rmd')
OUT_DIR := docs

all: pdf docx html wordcount.pdf

pdf: $(OUT_DIR)/thesis.tex

docx: $(OUT_DIR)/thesis.docx

html: $(OUT_DIR)/index.html

$(OUT_DIR)/thesis.tex: $(RMD) style/template.tex style/unimelbthesis.cls bib/references.bib
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"

$(OUT_DIR)/thesis.docx: $(RMD) style/template.docx bib/references.bib
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_word')"

$(OUT_DIR)/index.html: $(RMD) bib/references.bib
	Rscript -e "bookdown::render_book('index.Rmd', 'unimelbdown::thesis_gitbook')"

wordcount.txt: $(OUT_DIR)/thesis.tex
	# Copy .tex file for counting
	cp $(OUT_DIR)/thesis.tex $(OUT_DIR)/thesis_count.tex
	# Replace environment aliases for counting
	sed -i '' 's|\\Begin{|\\begin{|g' $(OUT_DIR)/thesis_count.tex
	sed -i '' 's|\\End{|\\end{|g' $(OUT_DIR)/thesis_count.tex
	# Replace chapter heading definition
	sed -i '' 's|\\titleformat{\\chapter|\\titleformat{\\Chapter|g' $(OUT_DIR)/thesis_count.tex
	sed -i '' 's|\\titleformat{name=\\chapter|\\titleformat{name=\\Chapter|g' $(OUT_DIR)/thesis_count.tex
	prettytc -c -l wordcount.txt $(OUT_DIR)/thesis_count.tex
	# Remove count .tex file
	rm $(OUT_DIR)/thesis_count.tex

wordcount.pdf: wordcount.txt R/plot_wordcount.R
	Rscript R/plot_wordcount.R
