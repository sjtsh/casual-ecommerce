
// const figureBestFeedbackWithPoints = (order) =>{
//     if(!order.feedbacks.length){
//         return 
//     }
//     if(order.feedbacks.length == 1){
//         return 0
//     }
//     var calculatedPointsForEachFeedback = []
//     var minOrderDistance = calculateMinimumOrderDistance(order)
//     var minDeliveryTime = calculateMinimumDeliveryTime(order)
//     var minDeliveryCharge = calculateMinimumDeliveryCharge(order)
//     var orderProductCount = order.items.length
//     for(var i in order.feedbacks){
//         var pointsForI = 0 
//         pointsForI += calculateWithPriority(compareNumberOfItems(order, i), 20)
//         // pointsForI += calculateWithPriority(compareTheDistance(order, minOrderDistance, i), 10)
//         // pointsForI += calculateWithPriority(compareAmounts(order, i), 20)
//         pointsForI += calculateWithPriority(compareDeliveryTime(order, minDeliveryTime,  i), 20)
//         pointsForI += calculateWithPriority(compareDeliveryCharge(order,minDeliveryCharge, i), 10)
//         pointsForI += calculateWithPriority(compareProductVariation(order, orderProductCount, i), 40)
//         calculatedPointsForEachFeedback.push(pointsForI)
//     }

//     var maxValue = calculatedPointsForEachFeedback[0]
//     var maxValueIndex = 0
//     for (var i in calculatedPointsForEachFeedback){
//         if(maxValue < calculatedPointsForEachFeedback[i]){
//             maxValueIndex = i
//             maxValue = calculatedPointsForEachFeedback[i]
//         }
//     }
//     return maxValueIndex
// }

// const compareDeliveryTime = (order, minDeliveryTime, index)=>{
//     if(order.feedbacks[index].deliveryTime == 0) return 1
//     return minDeliveryTime/order.feedbacks[index].deliveryTime
// }

// const compareProductVariation = (order, orderProductCount, index) =>{
//     if(orderProductCount == 0) return 1
//     return order.feedbacks[index].items.length/orderProductCount
// }

// const compareDeliveryCharge = (order, minDeliveryCharge, index) =>{
//     if(order.feedbacks[index].deliveryCharge == 0) return 1
//     return minDeliveryCharge/order.feedbacks[index].deliveryCharge
// }

// const compareAmounts = (order, index) =>{
//     var totalFeedbackAmountsTo = 0
//     var totalOrderAmountsTo = 0
//     for(var i in order.feedbacks[index].items){
//         totalFeedbackAmountsTo += order.feedbacks[index].items[i].total
//     }
//     for(var i in order.items){
//         totalOrderAmountsTo += order.items[i].total
//     }
    
//     if(totalFeedbackAmountsTo == 0) return 0
//     return totalOrderAmountsTo/totalFeedbackAmountsTo
// }

// const compareTheDistance = (order, minOrderDistance, i)=>{
    
//     if(order.feedbacks[i].distance == 0) return 1
//     return minOrderDistance/order.feedbacks[i].distance
// }

// const calculateMinimumDeliveryCharge = (order) => {
//     var minDeliveryCharge = order.feedbacks[0].deliveryCharge
//     for(var i in order.feedbacks){
//         if(minDeliveryCharge > order.feedbacks[i].deliveryCharge){
//             minDeliveryCharge = order.feedbacks[i].deliveryCharge
//         }
//     }
//     return minDeliveryCharge
// }

// const calculateMinimumDeliveryTime = (order) => {
//     var minDeliveryTime = order.feedbacks[0].deliveryTime
//     for(var i in order.feedbacks){
//         if(minDeliveryTime > order.feedbacks[i].deliveryTime){
//             minDeliveryTime = order.feedbacks[i].deliveryTime
//         }
//     }
//     return minDeliveryTime
// }

// const calculateMinimumOrderDistance = (order)=>{
//     var minDistance = order.feedbacks[0].distance
//     for(var i in order.feedbacks){
//         if(minDistance > order.feedbacks[i].distance){
//             minDistance = order.feedbacks[i].distance
//         }
//     }
//     return minDistance
// }


// const compareNumberOfItems = (order, index)=>{
//     var feedbackItemCount = 0
//     var orderItemCount = 0
//     for(var i in order.feedbacks[index].items){
//         feedbackItemCount += order.feedbacks[index].items[i].item_count
//     }
//     for(var i in order.items){
//         orderItemCount += order.items[i].item_count
//     }
//     if(orderItemCount == 0){
//         return 1
//     }
//     return feedbackItemCount/orderItemCount
// }

// const calculateWithPriority = (ratio, priorityInPercentage)=>{
//     return ratio * priorityInPercentage / 100
// }


// const decideByAvailability = (order) =>{
//     if(!order.feedbacks.length){
//         return 
//     }
//     var itemVariationCount = order.items.length
//     var feedbacksWithAllVariations = 0
//     for(var i in order.feedbacks){
//         if(order.feedbacks[i].items.length == itemVariationCount){
//             feedbacksWithAllVariations += 1
//         }
//     }
//     if(feedbacksWithAllVariations != 0){

//     }
// }