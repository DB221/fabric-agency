const table = document.getElementById("sup-tb");
const rows = document.getElementsByTagName("tr");

for (i = 0; i < rows.length; i++) {
  let currentRow = table.rows[i];
  let createClickHandler = (row) => {
    return function () {
      let cell = row.getElementsByTagName("td")[0];
      let sCode = cell.innerHTML;
      window.location = `/supplier/${sCode}/categories`;
    };
  };
  currentRow.onclick = createClickHandler(currentRow);
}
