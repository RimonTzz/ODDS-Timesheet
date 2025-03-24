// document.addEventListener('DOMContentLoaded', function() {
//     const tabs = document.querySelectorAll('#timesheet-tabs li');
//     const table = document.getElementById('timesheet-table');
//     const monthSelect = document.getElementById('month'); // สมมติว่ามี <select id="month">
  
//     function loadTimesheets(userProjectId, month) {
//         fetch(`/timesheets/data?user_project_id=${userProjectId}&month=${month}`)
//           .then(response => response.json())
//           .then(data => {
//             console.log("Timesheets received:", data);
//             updateTableBody(data.timesheets, data.work_statuses);
//           });
//       }
      
//       function updateTableBody(timesheets, workStatuses) {
//         const tableBody = document.getElementById('timesheet-table-body');
//         tableBody.innerHTML = '';
      
//         timesheets.forEach(timesheet => {
//           const row = document.createElement('tr');
//           row.innerHTML = `
//             <td>${timesheet.date}</td>
//             <td><input type="time" name="check_in" value="${timesheet.check_in || ''}"></td>
//             <td><input type="time" name="check_out" value="${timesheet.check_out || ''}"></td>
//             <td>
//               <select name="work_status">
//                 ${Object.keys(workStatuses).map(status => `
//                   <option value="${workStatuses[status]}" ${timesheet.work_status === workStatuses[status] ? 'selected' : ''}>${status}</option>
//                 `).join('')}
//               </select> 
//             </td>
//           `;
//           tableBody.appendChild(row);
//         });
//       }
      
  
//     tabs.forEach(tab => {
//       tab.addEventListener('click', function() {
//         const userProjectId = this.getAttribute('data-user-project-id');
//         table.setAttribute('data-user-project-id', userProjectId);
//         loadTimesheets(userProjectId, monthSelect.value);
//       });
//     });
  
//     monthSelect.addEventListener('change', function() {
//       const userProjectId = table.getAttribute('data-user-project-id');
//       loadTimesheets(userProjectId, this.value);
//     });
  
//     // โหลด Timesheets เริ่มต้น
//     loadTimesheets(table.getAttribute('data-user-project-id'), monthSelect.value);
//   });
