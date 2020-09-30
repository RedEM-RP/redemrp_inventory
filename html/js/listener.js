

$(function(){
			// show(true, true, true);
		// getItems(test , test);
	window.onload = (e) => {
		window.addEventListener('message', (event) => {
			console.log("par2ap");
			switch (event.data.type){
				case 1:	
					console.log(event.data.items)
					console.log("parap");
					show(event.data.inventory, event.data.otherinventory ,event.data.crafting);
					getItems(event.data.items, event.data.otheritems ,event.data.target , event.data.weight);
					  var money = document.getElementById("money");
					  var time = document.getElementById("clock");
					money.innerHTML = event.data.money+"$"
					time.innerHTML = event.data.time
				break;
				case 2:
					hide();
				break;
				default:
					hide();
			}
			console.log("wuwuw");
		});
	};
});
