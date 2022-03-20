// receives a <code> tag id as reference and copy its text to a temporary textAread element
// then selects the text in the textArea and copy this to the clipboard, finally deletes
// the temporary textAread
function fnCopyText(codeId) {
    const copyText = document.getElementById(codeId).textContent;
    const textArea = document.createElement('textarea');
    textArea.className = "copy-txt-area";
    textArea.style.position = "absolute";
    // textArea.style.left = -100;
    textArea.textContent = copyText;
    document.body.append(textArea);
    textArea.select();
    document.execCommand("copy");
    textArea.remove();
}

// adds a copy button to all the <pre><code> snippets
function fnAddCopyButtons() {

    var pres = document.getElementsByTagName("pre");

    for (let i = 0; i < pres.length; i++) {

        // add an id to the code tag
        let preTag = pres[i];
        let codeTag = preTag.firstElementChild;
        codeTag.id = "code-" + i;

        // creat a button with same id as pre
        let btn = document.createElement("button");
        btn.id = "btn-" + i;
        btn.innerHTML = "Copy";
        btn.className = "copy-button";
        // add button bootstrap style
        btn.className += " nav-item m-2 border border-primary rounded";

        // when the button is clicked it will call the fnCopyText function
        btn.addEventListener('click', function() { fnCopyText(codeTag.id) });

        // add a copy button before the code
        preTag.insertBefore(btn, preTag.firstElementChild);
    }
}

// on page load setup
fnAddCopyButtons();