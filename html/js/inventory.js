var targetPlayerId = 0;
function createObjectBox(object) {

 const box = document.createElement("div");
 box.setAttribute('class', 'item');
 box.setAttribute('data-amount', object.amount);
 if (object.box > 3) {
  document.getElementsByClassName(`slot${object.box-3}`)[0].appendChild(box);
 } else {
  document.getElementsByClassName(`box${object.box}`)[0].appendChild(box);
 }

 const boxContent = document.createElement("div");
 box.appendChild(boxContent);
 boxContent.setAttribute('class', 'item-content');
 boxContent.setAttribute('objectId', object.id);
 boxContent.setAttribute('oncontextmenu', `cloneBox(${object.id})`);
 boxContent.setAttribute('ondblclick', `cloneBox2(${object.id})`);
 boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `" + object.description + "`)    "     );



 const mainContent = document.createElement("div");
 mainContent.setAttribute('class', 'item-content-main');
 boxContent.appendChild(mainContent);

 const img = document.createElement("img");
 img.src = object.imgsrc;
 img.style.position = 'absolute';
 img.style.left = '50%';
 img.style.height = '90%';
 img.style.marginRight = '-50%';
 img.style.transform = 'translate(-50%, 0%)';
 mainContent.appendChild(img);

 const sliderBox = document.createElement("div");
 sliderBox.setAttribute('class', 'item-content-footer');
 sliderBox.style.display = 'none';
 boxContent.appendChild(sliderBox);

 const amountBox = document.createElement("div");
 boxContent.appendChild(amountBox);
 amountBox.setAttribute('class', 'item-content-footer');
 amountBox.innerHTML = object.amount;

 return box;
}



function cloneBox(id) {
 object = getObjectById(id);

 if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;

 neighbour = getObjectsByNameAndMeta(object.name, object.meta).find(obj => obj.box == object.box && obj.id != id);
 setObjectAmount(id, object.amount - 1, false);

 if (neighbour) setObjectAmount(neighbour.id, neighbour.amount + 1, false);
 else return addObject({
  name: object.name,
  description: object.description,
  label : object.label,
  type : object.type,
  amount: 1,
  imgsrc: object.imgsrc,
  box: object.box,
  meta: object.meta
 });
}



function cloneBox2(id) {
 object = getObjectById(id);
 
 if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;
 var val = Math.floor(object.amount / 2);
 setObjectAmount(id, object.amount - val, false);
 addObject({
  name: object.name,
  description: object.description,
     label : object.label,
  type : object.type,
  amount: val,
  imgsrc: object.imgsrc,
  box: object.box,
  meta: object.meta
 });
}

function addObject(data) {
 id = objects.length ? objects[objects.length - 1].id + 1 : 1;
 obj = {
  id: id,
  name: data.name,
  description: data.description,
      label : data.label,
  type : data.type,
  meta: data.meta,
  amount: data.amount,
  imgsrc: data.imgsrc,
  box: data.box,
 };
 objects.push(obj);
 grids[parseInt(data.box)].add(createObjectBox(obj))[0]._id = id;
 return obj;
}

function getObjectById(id) {
 return objects.find(obj => obj.id == id);
}

function getObjectsByNameAndMeta(name, meta) {
 return objects.filter(obj => obj.name == name && obj.meta == meta);
}

function getAmountSum(name, meta) {
 return getObjectsByNameAndMeta(name, meta).reduce((sum, {
  amount
 }) => sum + amount, 0);
}

function getObjectHTML(objectId) {
 return document.querySelector(`[objectId='${objectId}']`);
}

function setObjectAmount(id, amount, affectOnOthers = true) {
 if (amount <= 0) {
  removeObjects([getObjectById(id)]);
  return;
 }
 object = getObjectById(id);
 difference = parseInt(amount) - object.amount;

 object.amount = parseInt(amount);
 boxContent = getObjectHTML(id);
 boxContent.lastChild.innerHTML = amount;
 if (difference == 0 || !affectOnOthers) return;
 if (getObjectsByNameAndMeta(object.name, object.meta).length == 1) {
  addObject({
   name: object.name,
   description: object.description,
     label : object.label,
  type : object.type,
   meta: object.meta,
   amount: -difference,
   imgsrc: object.imgsrc,
   box: object.box
  });
  return;
 }

 for (const destinationBox of objectsMoveDirections[object.box]) {
  destinationObjects = getObjectsByNameAndMeta(object.name, object.meta).filter(obj => obj.box == destinationBox && obj.id != id);

  for (const destinationobject of destinationObjects) {
   if (destinationobject.amount >= difference) {
    setObjectAmount(destinationobject.id, destinationobject.amount - difference, false);
    return;
   } else {
    difference -= destinationobject.amount;
    setObjectAmount(destinationobject.id, 0, false);
   }
  }
 }
}

function getObjectsFromBox(box_nr) {
 return objects.filter(({
  box
 }) => box == box_nr);
}

function onDragFinished(data) {

 // get dragged object
 draggedObject = getObjectById(data.item._id);
 // get all repeated elements

 repeats = getObjectsFromBox(data.toGrid._id - 1).filter(({
  name,
  meta
 }) => name == draggedObject.name && deepEqual(meta, draggedObject.meta));
 if (draggedObject.type == "item_standard" ) {
 // add amount of objects from this box
 repeatsAmount = repeats.reduce((sum, {
  amount
 }) => sum + amount, 0);
 setObjectAmount(data.item._id, draggedObject.amount + repeatsAmount, false);
 }
 // set new box value to object
 getObjectById(data.item._id).box = data.toGrid._id - 1;
 // remove all repeats

 removeObjects(repeats);
}

function deepEqual(object1, object2) {
 const keys1 = Object.keys(object1);
 const keys2 = Object.keys(object2);

 if (keys1.length !== keys2.length) {
  return false;
 }

 for (const key of keys1) {
  const val1 = object1[key];
  const val2 = object2[key];
  const areObjects = isObject(val1) && isObject(val2);
  if (
   areObjects && !deepEqual(val1, val2) ||
   !areObjects && val1 !== val2
  ) {
   return false;
  }
 }

 return true;
}

function isObject(object) {
 return object != null && typeof object === 'object';
}


function removeObjects(arrayOfObjects) {
 arrayOfObjects.forEach(obj => {
  //Remove from grid
  grids[parseInt(obj.box)].remove(grids[parseInt(obj.box)].getItems().find(({
   _id
  }) => _id == obj.id));
  //Delete HTML element
  box = getObjectHTML(obj.id).parentElement;
  box.parentElement.removeChild(box);
  //Remove from objects array
  objects = objects.filter(obj => !arrayOfObjects.find(el => el.id == obj.id))
 })
}

const objectsMoveDirections = [
 [0, 1, 2],
 [1, 0, 2],
 [2, 1, 0]
];

let objects = [];
hide();
let objectsIn = null;
var secondInventoryId = -1

var grids = [
 new Muuri('.box0', {
  dragEnabled: true,
  dragContainer: document.body,
  dragSort: () => grids,
   sortData: {
    amount: function (item, element) {
      return parseFloat(element.getAttribute('data-amount'));
    }
  },
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data))
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '15.2%';
  item.getElement().style.height = '8vh';
  grids.forEach(function(grid) {
   grid.refreshItems();
  });
 }),


 new Muuri('.box1', {
  dragEnabled: true,
  dragContainer: document.body,
  dragSort: () => grids,
  sortData: {
    amount: function (item, element) {
      return parseFloat(element.getAttribute('data-amount'));
    }
  },
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }) .on('send', function(data) {
	if (data.toGrid._id == 1) {
	 var object = getObjectById(data.item._id);
	 $.post('http:/redemrp_inventory/removeitem', JSON.stringify({data:object, target:targetPlayerId}), );
	}
	 onDragFinished(data)}
	 )
  .on('beforeReceive', function(data) {
	 if (data.fromGrid._id == 1) {
		var object = getObjectById(data.item._id);
		$.post('http:/redemrp_inventory/additem', JSON.stringify({data:object , target:targetPlayerId}), );
	 }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '15.2%';
  item.getElement().style.height = '8vh';
  grids.forEach(function(grid) {
   grid.refreshItems();
  });
 }),


 new Muuri('.box2', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {

   handle: '.item-content-main, .item-content-amount-moved'
  }
 })
   .on('receive', function(data) {
	 if (data.fromGrid._id == 2) {
		var object = getObjectById(data.item._id);
	
		$.post('http:/redemrp_inventory/dropitem', JSON.stringify({data:object}), );
	 }else{
		 ItemBack(data); 
	 }
	  })
 .on('send', data => onDragFinished(data))
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '15.2%';
  item.getElement().style.height = '8vh';
  grids.forEach(function(grid) {
   grid.refreshItems();
  });
 }),
 
 
 new Muuri('.box3', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {

   handle: '.item-content-main, .item-content-amount-moved'
  }
 })
    .on('receive', function(data) {
	
	 if (data.fromGrid._id == 2) {
		var object = getObjectById(data.item._id);
		$.post('http:/redemrp_inventory/useitem', JSON.stringify({data:object}), );
		 ItemBack(data); 
	 }else{
		 ItemBack(data); 
	 }
	  })
 .on('send', data => onDragFinished(data))
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '15.2%';
  item.getElement().style.height = '8vh';
  grids.forEach(function(grid) {
   grid.refreshItems();
  });
 }),

 new Muuri('.slot1', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data))
 .on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';
 }),

 new Muuri('.slot2', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),


 new Muuri('.slot3', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),

 new Muuri('.slot4', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),

 new Muuri('.slot5', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
   item.getElement().style.width = '85%';
   item.getElement().style.height = '85%';

 }),

 new Muuri('.slot6', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),

 new Muuri('.slot7', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),

 new Muuri('.slot8', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';

 }),

 new Muuri('.slot9', {
  dragEnabled: true,
  dragSort: () => grids,
  dragContainer: document.body,
  dragStartPredicate: {
   handle: '.item-content-main, .item-content-amount-moved'
  }
 }).on('send', data => onDragFinished(data)).on('receive', function(data) {
  if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
   ItemBack(data);
  }
 })
 .on('dragStart', function(item) {
  item.getElement().style.width = item.getWidth() + 'px';
  item.getElement().style.height = item.getHeight() + 'px';
 })
 
 .on('dragReleaseEnd', function(item) {
  item.getElement().style.width = '85%';
  item.getElement().style.height = '85%';
 }),
];

function hide() {
 document.body.style.display = 'none';
}

function GetNumberOfItems(data) {
 return grids[data.toGrid._id - 1]._items.length;
}

$( "#craftButton" ).click(function() {
  $.post('http:/redemrp_inventory/craft', JSON.stringify({  
	  slot_1: GetCraftingSlotData(4),
	  slot_2: GetCraftingSlotData(5),
	  slot_3: GetCraftingSlotData(6),
	  slot_4: GetCraftingSlotData(7),
	  slot_5: GetCraftingSlotData(8),
	  slot_6: GetCraftingSlotData(9),
	  slot_7: GetCraftingSlotData(10),
	  slot_8: GetCraftingSlotData(11),
	  slot_9: GetCraftingSlotData(12),
	  }), );
});

function GetCraftingSlotData(id)
{
	var name = "empty";
	var amount = 0;
        var meta = [];
	
	if (grids[id]._items[0] != null) {
	var itemId = grids[id]._items[0]._id
	var object = getObjectById(itemId);
	name = object.name;
	amount = object.amount;
    meta = object.meta;
	}	

	return [name, amount, meta]

}

function ItemBack(data) {
 var object = getObjectById(data.item._id);
 if (data.fromGrid._id > 4) {
 addObject({
  name: object.name,
  meta: object.meta,
  label : object.label,
  type : object.type,
  amount: object.amount,
  imgsrc: object.imgsrc,
  box: 1,
 });  
 }else{
  addObject({
  name: object.name,
  meta: object.meta,
  label : object.label,
  type : object.type,
  amount: object.amount,
  imgsrc: object.imgsrc,
  box: data.fromGrid._id - 1
 });  
 }
removeObjects([object]);
grids[0].sort('amount:desc',{layout: 'instant'});
grids[1].sort('amount:desc',{layout: 'instant'});
}

function show(playerInventory, otherInventory, crafting) {
 document.body.style.display = 'block';

 document.getElementsByClassName('box0')[0].style.display = (otherInventory) ? 'block' : 'none';
 document.getElementsByClassName('box1')[0].style.display = (playerInventory) ? 'block' : 'none';
 document.getElementsByClassName('grid')[0].style.display = (crafting) ? 'block' : 'none';
 document.getElementsByClassName('invCraft')[0].style.display = (crafting) ? 'block' : 'none';
}
var shiftactive = false;
$(document).keydown(function(e) {
	if (e.keyCode == 16) {
		shiftactive = true;
	}
});

   grids[1].on('dragMove', function(item, event) {
    var i;
	if (shiftactive){
    for (i = 0; i < objects.length; i++) {

     if (parseInt(item._id) !== parseInt(objects[i].id)) {
      if (getObjectHTML(item._id) != null) {
       var coords = getObjectHTML(item._id).getBoundingClientRect();
       var coords2 = getObjectHTML(objects[i].id).getBoundingClientRect();
       var a = coords.top - coords2.top;
       var b = coords.left - coords2.left;
       var c = Math.sqrt(a * a + b * b);

       if (c < 40) {
        var object = getObjectById(objects[i].id);
        var object2 = getObjectById(item._id);
        if (object2.name == object.name && deepEqual(object2.meta, object.meta)) {
         
         boxContent = getObjectHTML(item._id);
         boxContent.lastChild.innerHTML = parseInt(object2.amount + object.amount);
         object2.amount = parseInt(object2.amount + object.amount);
         removeObjects([object]);
        }
       }
      }
     }
	 shiftactive = false;
	}
    }
 });



function Over(item, desc) {
   var name = document.getElementById("info2");
   var opis = document.getElementById("info3");
   if (item == null) {
	name.innerHTML = "";
	opis.innerHTML = "";
   } else {
   	name.innerHTML = item;
	opis.innerHTML = desc;
	}
}



async function getItems(data, secondInventory, targetPlayer , weight) {
 objectsIn = data;
 targetPlayerId = targetPlayer;
 removeObjects(objects);
for (x in data) { 
	 data[x].box = 1;
	 addObject(data[x]);
 }
 if (secondInventory){
	for (x in secondInventory) { 
	 secondInventory[x].box = 0;
	 addObject(secondInventory[x]);
 } 	 
 }
  var weight_object = document.getElementById("weight");
weight_object.innerHTML = Math.round(weight * 100) / 100+" / 24 KG";
grids[0].sort('amount:desc',{layout: 'instant'});
grids[1].sort('amount:desc',{layout: 'instant'});
}



$(document).keyup(function(e) {
 if (e.keyCode == 27 || e.keyCode == 66) { //hide eq

  hide();
  $.post('http:/redemrp_inventory/close');
 }
});



